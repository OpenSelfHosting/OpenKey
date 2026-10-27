import 'package:equatable/equatable.dart';
import 'package:openkey_app/src/core/database/reserved_collections.dart';

/// Reserved collection id for payment-card wallet entries in the encrypted DB.
abstract final class WalletIds {
  static const collectionUuid = ReservedCollections.wallets;

  static bool isReserved(String? id) => id == collectionUuid;
}

enum CardBrand {
  visa,
  mastercard,
  amex,
  discover,
  unionpay,
  rupay,
  elo,
  hipercard,
  mir,
  other;

  String get label => switch (this) {
    CardBrand.visa => 'Visa',
    CardBrand.mastercard => 'Mastercard',
    CardBrand.amex => 'Amex',
    CardBrand.discover => 'Discover',
    CardBrand.unionpay => 'UnionPay',
    CardBrand.rupay => 'RuPay',
    CardBrand.elo => 'Elo',
    CardBrand.hipercard => 'Hipercard',
    CardBrand.mir => 'Mir',
    CardBrand.other => 'Card',
  };

  /// BIN prefixes matching `flutter_credit_card` (longest / specific first).
  static const _ranges = <(int, int?, CardBrand)>[
    // 6…
    (655021, 655058, CardBrand.elo),
    (655000, 655019, CardBrand.elo),
    (6521, 6522, CardBrand.rupay),
    (651652, 651679, CardBrand.elo),
    (650901, 650978, CardBrand.elo),
    (650720, 650727, CardBrand.elo),
    (650700, 650718, CardBrand.elo),
    (650541, 650598, CardBrand.elo),
    (650485, 650538, CardBrand.elo),
    (650405, 650439, CardBrand.elo),
    (650035, 650051, CardBrand.elo),
    (650031, 650033, CardBrand.elo),
    (65, null, CardBrand.discover),
    (644, 649, CardBrand.discover),
    (636368, null, CardBrand.elo),
    (636297, null, CardBrand.elo),
    (627780, null, CardBrand.elo),
    (622126, 622925, CardBrand.discover),
    (62, null, CardBrand.unionpay),
    (606282, null, CardBrand.hipercard),
    (6011, null, CardBrand.discover),
    (60, null, CardBrand.rupay),
    // 5…
    (56, 59, CardBrand.mastercard),
    (51, 55, CardBrand.mastercard),
    (509000, 509999, CardBrand.elo),
    (506699, 506778, CardBrand.elo),
    (504175, null, CardBrand.elo),
    (50, null, CardBrand.mastercard),
    // 4…
    (457631, 457632, CardBrand.elo),
    (457393, null, CardBrand.elo),
    (451416, null, CardBrand.elo),
    (438935, null, CardBrand.elo),
    (431274, null, CardBrand.elo),
    (401178, 401179, CardBrand.elo),
    (4, null, CardBrand.visa),
    // 3…
    (34, 37, CardBrand.amex),
    // 2…
    (2720, null, CardBrand.mastercard),
    (270, 271, CardBrand.mastercard),
    (23, 26, CardBrand.mastercard),
    (223, 229, CardBrand.mastercard),
    (2221, 2229, CardBrand.mastercard),
    (2200, 2204, CardBrand.mir),
  ];

  static CardBrand detect(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return CardBrand.other;
    for (final (start, end, brand) in _ranges) {
      if (_prefixMatches(digits, start, end)) return brand;
    }
    return CardBrand.other;
  }

  static bool _prefixMatches(String digits, int start, int? end) {
    final len = start.toString().length;
    if (digits.length < len) return false;
    final prefix = int.parse(digits.substring(0, len));
    if (end == null) return prefix == start;
    return prefix >= start && prefix <= end;
  }

  static CardBrand fromName(String? name) {
    return switch (name?.toLowerCase().trim()) {
      'visa' => CardBrand.visa,
      'mastercard' || 'maestro' => CardBrand.mastercard,
      'amex' || 'american express' || 'americanexpress' => CardBrand.amex,
      'discover' => CardBrand.discover,
      'unionpay' || 'union pay' => CardBrand.unionpay,
      'rupay' || 'ru pay' => CardBrand.rupay,
      'elo' => CardBrand.elo,
      'hipercard' => CardBrand.hipercard,
      'mir' => CardBrand.mir,
      _ => CardBrand.other,
    };
  }
}

class WalletCard extends Equatable {
  const WalletCard({
    required this.uuid,
    this.name = '',
    this.holder = '',
    this.number = '',
    this.expiry = '',
    this.cvc = '',
    this.brand = CardBrand.other,
    this.notes = '',

    /// Bank / issuer label used to group cards (e.g. "Al Rajhi").
    this.bank = '',
    this.revision = 1,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uuid;
  final String name;
  final String holder;
  final String number;
  final String expiry;
  final String cvc;
  final CardBrand brand;
  final String notes;

  /// Logical bank folder inside Cards.
  final String bank;
  final int revision;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName => name.trim().isNotEmpty ? name.trim() : brand.label;

  /// Group key for UI sections — empty bank sorts under a shared bucket.
  String get bankGroup {
    final b = bank.trim();
    return b.isEmpty ? '' : b;
  }

  String get maskedNumber {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return '••••';
    return '•••• ${digits.substring(digits.length - 4)}';
  }

  String get spacedNumber {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  WalletCard copyWith({
    String? uuid,
    String? name,
    String? holder,
    String? number,
    String? expiry,
    String? cvc,
    CardBrand? brand,
    String? notes,
    String? bank,
    int? revision,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletCard(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      holder: holder ?? this.holder,
      number: number ?? this.number,
      expiry: expiry ?? this.expiry,
      cvc: cvc ?? this.cvc,
      brand: brand ?? this.brand,
      notes: notes ?? this.notes,
      bank: bank ?? this.bank,
      revision: revision ?? this.revision,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toPayload() => {
    'type': 'card',
    'name': name,
    'holder': holder,
    'number': number,
    'expiry': expiry,
    'cvc': cvc,
    'brand': brand.name,
    'notes': notes,
    if (bank.trim().isNotEmpty) 'bank': bank.trim(),
  };

  factory WalletCard.fromPayload({
    required String uuid,
    required Map<String, dynamic> payload,
    int revision = 1,
    bool isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final number = payload['number']?.toString() ?? '';
    final brandName = payload['brand']?.toString();
    return WalletCard(
      uuid: uuid,
      name: payload['name']?.toString() ?? '',
      holder: payload['holder']?.toString() ?? '',
      number: number,
      expiry: payload['expiry']?.toString() ?? '',
      cvc: payload['cvc']?.toString() ?? '',
      brand: brandName != null && brandName.isNotEmpty
          ? CardBrand.fromName(brandName)
          : CardBrand.detect(number),
      notes: payload['notes']?.toString() ?? '',
      bank: payload['bank']?.toString() ?? '',
      revision: revision,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    name,
    holder,
    number,
    expiry,
    cvc,
    brand,
    notes,
    bank,
    revision,
  ];
}
