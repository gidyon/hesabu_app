class WithdrawalTariffsResponse {
  const WithdrawalTariffsResponse({
    required this.serviceId,
    required this.tariffs,
    required this.totalRanges,
  });

  final String serviceId;
  final List<WithdrawalTariff> tariffs;
  final int totalRanges;

  factory WithdrawalTariffsResponse.fromJson(Object? payload) {
    if (payload is! Map) {
      throw const FormatException('Invalid withdrawal tariff response.');
    }

    final tariffsJson = payload['tariffs'];
    if (tariffsJson is! List) {
      throw const FormatException('Withdrawal tariff ranges are missing.');
    }

    final tariffs = tariffsJson
        .map(WithdrawalTariff.fromJson)
        .toList(growable: false);
    final totalRanges = _requiredInt(payload['total_ranges'], 'total_ranges');
    if (tariffs.length != totalRanges) {
      throw const FormatException(
        'Withdrawal tariff range count does not match the API response.',
      );
    }

    return WithdrawalTariffsResponse(
      serviceId: payload['service_id']?.toString() ?? '',
      tariffs: tariffs,
      totalRanges: totalRanges,
    );
  }

  double feeFor(double amount) {
    if (!amount.isFinite || amount <= 0) {
      throw const FormatException(
        'Withdrawal amount must be greater than zero.',
      );
    }

    final matches = tariffs
        .where((tariff) => tariff.contains(amount))
        .toList(growable: false);
    if (matches.isEmpty) {
      throw const FormatException(
        'No current withdrawal tariff matches this amount.',
      );
    }
    if (matches.length > 1) {
      throw const FormatException(
        'The withdrawal tariff response contains overlapping ranges.',
      );
    }
    return matches.single.totalFee;
  }
}

class WithdrawalTariff {
  const WithdrawalTariff({
    required this.displayFee,
    required this.hesabuOnlineFee,
    required this.maxAmount,
    required this.minAmount,
    required this.mpesaFee,
    required this.range,
    required this.totalFee,
  });

  final String displayFee;
  final double hesabuOnlineFee;
  final double maxAmount;
  final double minAmount;
  final double mpesaFee;
  final String range;
  final double totalFee;

  factory WithdrawalTariff.fromJson(Object? payload) {
    if (payload is! Map) {
      throw const FormatException('Invalid withdrawal tariff range.');
    }

    final minAmount = _requiredDouble(payload['min_amount'], 'min_amount');
    final maxAmount = _requiredDouble(payload['max_amount'], 'max_amount');
    if (minAmount > maxAmount) {
      throw const FormatException('Invalid withdrawal tariff amount range.');
    }

    return WithdrawalTariff(
      displayFee: payload['display_fee']?.toString() ?? '',
      hesabuOnlineFee: _requiredDouble(
        payload['hesabu_online_fee'],
        'hesabu_online_fee',
      ),
      maxAmount: maxAmount,
      minAmount: minAmount,
      mpesaFee: _requiredDouble(payload['mpesa_fee'], 'mpesa_fee'),
      range: payload['range']?.toString() ?? '',
      totalFee: _requiredDouble(payload['total_fee'], 'total_fee'),
    );
  }

  bool contains(double amount) => amount >= minAmount && amount <= maxAmount;
}

double _requiredDouble(Object? value, String field) {
  final parsed = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');
  if (parsed == null || !parsed.isFinite || parsed < 0) {
    throw FormatException('Invalid $field in withdrawal tariff response.');
  }
  return parsed;
}

int _requiredInt(Object? value, String field) {
  final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
  if (parsed == null || parsed < 0) {
    throw FormatException('Invalid $field in withdrawal tariff response.');
  }
  return parsed;
}
