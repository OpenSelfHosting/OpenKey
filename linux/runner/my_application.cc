#include "my_application.h"

#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>
#include <flutter_linux/flutter_linux.h>

#include "autofill_bridge.h"
#include "flutter/generated_plugin_registrant.h"

#include <glib/gstdio.h>
#include <string.h>

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static gchar* openkey_executable_dir() {
  g_autoptr(GError) error = nullptr;
  g_autofree gchar* exe = g_file_read_link("/proc/self/exe", &error);
  if (exe == nullptr) {
    return nullptr;
  }
  return g_path_get_dirname(exe);
}

// Icon shipped next to the binary (CMake) or in the bundle's hicolor tree.
static gchar* openkey_find_bundled_icon() {
  g_autofree gchar* exe_dir = openkey_executable_dir();
  if (exe_dir == nullptr) {
    return nullptr;
  }
  const gchar* relative_paths[] = {
      "openkey.png",
      "share/icons/hicolor/256x256/apps/" APPLICATION_ID ".png",
      "share/icons/hicolor/256x256/apps/openkey.png",
      nullptr,
  };
  for (int i = 0; relative_paths[i] != nullptr; ++i) {
    g_autofree gchar* candidate =
        g_build_filename(exe_dir, relative_paths[i], nullptr);
    if (g_file_test(candidate, G_FILE_TEST_IS_REGULAR)) {
      return g_steal_pointer(&candidate);
    }
  }
  return nullptr;
}

static gboolean openkey_file_contains(const gchar* path, const gchar* needle) {
  g_autofree gchar* contents = nullptr;
  if (!g_file_get_contents(path, &contents, nullptr, nullptr) ||
      contents == nullptr) {
    return FALSE;
  }
  return strstr(contents, needle) != nullptr;
}

static gboolean openkey_system_desktop_installed() {
  const gchar* const* dirs = g_get_system_data_dirs();
  for (const gchar* const* dir = dirs; dir != nullptr && *dir != nullptr;
       ++dir) {
    g_autofree gchar* path = g_build_filename(
        *dir, "applications", APPLICATION_ID ".desktop", nullptr);
    if (g_file_test(path, G_FILE_TEST_IS_REGULAR)) {
      return TRUE;
    }
  }
  return FALSE;
}

// GNOME (Wayland) looks up APPLICATION_ID.desktop in XDG data dirs — not the
// window pixmap. Unpackaged `flutter run` has no system .desktop file, so we
// publish a user-local one before the window is mapped.
static void openkey_install_user_desktop_entry(const gchar* icon_path) {
  if (g_getenv("FLATPAK_ID") != nullptr || g_getenv("SNAP") != nullptr) {
    return;
  }

  g_autofree gchar* desktop_dir =
      g_build_filename(g_get_user_data_dir(), "applications", nullptr);
  g_autofree gchar* desktop_path = g_build_filename(
      desktop_dir, APPLICATION_ID ".desktop", nullptr);

  const gboolean user_exists =
      g_file_test(desktop_path, G_FILE_TEST_IS_REGULAR);
  const gboolean user_generated =
      user_exists &&
      openkey_file_contains(desktop_path, "X-OpenKey-Generated=true");
  const gboolean system_exists = openkey_system_desktop_installed();

  // A user-local file with the same id as the package overrides /usr/share.
  // NoDisplay=true here would hide the installed app from GNOME's grid.
  if (system_exists) {
    if (user_generated) {
      g_unlink(desktop_path);
    }
    return;
  }
  if (icon_path == nullptr) {
    return;
  }
  if (user_exists && !user_generated) {
    return;
  }

  g_autofree gchar* exe = g_file_read_link("/proc/self/exe", nullptr);
  if (exe == nullptr) {
    return;
  }

  g_mkdir_with_parents(desktop_dir, 0755);

  g_autofree gchar* icon_dir = g_build_filename(
      g_get_user_data_dir(), "icons", "hicolor", "256x256", "apps", nullptr);
  g_mkdir_with_parents(icon_dir, 0755);
  g_autofree gchar* themed_icon = g_build_filename(
      icon_dir, APPLICATION_ID ".png", nullptr);
  g_autoptr(GError) copy_error = nullptr;
  g_autoptr(GFile) icon_src = g_file_new_for_path(icon_path);
  g_autoptr(GFile) icon_dst = g_file_new_for_path(themed_icon);
  g_file_copy(icon_src, icon_dst,
              static_cast<GFileCopyFlags>(G_FILE_COPY_OVERWRITE |
                                          G_FILE_COPY_TARGET_DEFAULT_PERMS),
              nullptr, nullptr, nullptr, &copy_error);
  const gchar* desktop_icon =
      copy_error == nullptr ? themed_icon : icon_path;

  g_autofree gchar* quoted_exec = g_shell_quote(exe);
  g_autofree gchar* body = g_strdup_printf(
      "[Desktop Entry]\n"
      "Type=Application\n"
      "Version=1.0\n"
      "Name=OpenKey\n"
      "GenericName=Password Manager\n"
      "Comment=Self-hosted end-to-end encrypted password manager\n"
      "Exec=%s\n"
      "Icon=%s\n"
      "Terminal=false\n"
      "Categories=Utility;Security;\n"
      "Keywords=password;vault;credentials;security;\n"
      "StartupNotify=true\n"
      "StartupWMClass=%s\n"
      "X-OpenKey-Generated=true\n"
      "X-GNOME-UsesNotifications=false\n",
      quoted_exec, desktop_icon, APPLICATION_ID);
  g_file_set_contents(desktop_path, body, -1, nullptr);
}

static void openkey_apply_window_icon(GtkWindow* window) {
  g_autofree gchar* icon_path = openkey_find_bundled_icon();
  if (icon_path == nullptr) {
    gtk_window_set_icon_name(window, APPLICATION_ID);
    return;
  }
  gtk_window_set_icon_from_file(window, icon_path, nullptr);
  gtk_window_set_default_icon_from_file(icon_path, nullptr);
}

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Custom Flutter title bar via bitsdojo_window (undecorated frame).
  gtk_window_set_title(window, "OpenKey");
  auto bdw = bitsdojo_window_from(window);
  bdw->setCustomFrame(true);
  // Size is set from Dart (doWhenWindowReady).
  // gtk_window_set_default_size(window, 1280, 720);
  openkey_apply_window_icon(window);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
  setup_autofill_channel(view);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);

  g_autofree gchar* icon_path = openkey_find_bundled_icon();
  if (icon_path != nullptr) {
    gtk_window_set_default_icon_from_file(icon_path, nullptr);
  }
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  g_autofree gchar* icon_path = openkey_find_bundled_icon();
  openkey_install_user_desktop_entry(icon_path);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
