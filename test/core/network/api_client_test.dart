import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/core/network/api_client.dart';
import 'package:hesabu_app/core/network/insecure_tls_adapter.dart';

void main() {
  test('uses the configured default API URL', () {
    expect(Uri.parse(ApiClient.defaultBaseUrl).scheme, 'https');
    expect(ApiClient().dio.options.baseUrl, ApiClient.baseUrl);
  });

  test('insecure TLS is disabled by default', () {
    expect(ApiClient.insecureTlsEnabled, isFalse);
  });

  test('insecure TLS policy only permits the configured host and port', () {
    expect(
      isAllowedInsecureTlsEndpoint(
        requestHost: 'app.hesabuonline.com',
        requestPort: 443,
        allowedHost: 'app.hesabuonline.com',
        allowedPort: 443,
      ),
      isTrue,
    );
    expect(
      isAllowedInsecureTlsEndpoint(
        requestHost: 'attacker.example',
        requestPort: 443,
        allowedHost: 'app.hesabuonline.com',
        allowedPort: 443,
      ),
      isFalse,
    );
    expect(
      isAllowedInsecureTlsEndpoint(
        requestHost: 'app.hesabuonline.com',
        requestPort: 8443,
        allowedHost: 'app.hesabuonline.com',
        allowedPort: 443,
      ),
      isFalse,
    );
  });
}
