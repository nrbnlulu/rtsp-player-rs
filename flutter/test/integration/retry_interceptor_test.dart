import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gstreamer/flutter_gstreamer.dart';
import 'package:flutter_gstreamer/src/rust/api/error.dart' as rust_error;
import 'package:flutter_gstreamer/src/rust/api/http.dart' as rust_http;
import 'package:flutter_gstreamer/src/rust/frb_generated.dart';

import '../mocks.dart';

void main() {
  late MockRustLibApi mockApi;

  setUpAll(() async {
    mockApi = MockRustLibApi.createAndRegister();

    RustLib.initMock(api: mockApi);
  });

  test('Should retry once', () async {
    int requestCount = 0;
    mockApi.mockCustomResponse(
      body: 'Retried!',
      onAnswer: (_) {
        requestCount++;
        if (requestCount == 1) {
          throw const rust_error
              .flutter_gstreamerError_flutter_gstreamerUnknownError(
              'Failed 123');
        }
      },
    );

    flutter_gstreamerException? exceptionInBeforeRetry;
    final response = await flutter_gstreamer.post(
      'https://example.com',
      interceptors: [
        RetryInterceptor(
          beforeRetry: (attempt, request, response, exception) async {
            exceptionInBeforeRetry = exception;
            return null;
          },
        ),
      ],
    );

    expect(response.body, 'Retried!');
    expect(requestCount, 2);
    expect(
      (exceptionInBeforeRetry as flutter_gstreamerUnknownException).message,
      'Failed 123',
    );
  });

  test('Should call next interceptor after successful retry', () async {
    int requestCount = 0;
    mockApi.mockCustomResponse(
      body: 'Retried!',
      onAnswer: (_) {
        requestCount++;
        if (requestCount == 1) {
          throw const rust_error
              .flutter_gstreamerError_flutter_gstreamerUnknownError(
              'Failed 222');
        }
      },
    );

    flutter_gstreamerException? exceptionInBeforeRetry;
    int secondInterceptorCalled = 0;
    final response = await flutter_gstreamer.post(
      'https://example.com',
      interceptors: [
        RetryInterceptor(
          beforeRetry: (attempt, request, response, exception) async {
            exceptionInBeforeRetry = exception;
            return null;
          },
        ),
        SimpleInterceptor(
          afterResponse: (response) async {
            secondInterceptorCalled++;
            return Interceptor.next();
          },
        )
      ],
    );

    expect(response.body, 'Retried!');
    expect(requestCount, 2);
    expect(
      (exceptionInBeforeRetry as flutter_gstreamerUnknownException).message,
      'Failed 222',
    );
    expect(secondInterceptorCalled, 1);
  });

  test('Should fail after retrying once and it also fails', () async {
    int requestCount = 0;
    mockApi.mockCustomResponse(
      body: 'Retried!',
      onAnswer: (_) {
        requestCount++;
        if (requestCount <= 2) {
          throw const rust_error
              .flutter_gstreamerError_flutter_gstreamerUnknownError(
              'Failed 111');
        }
      },
    );

    flutter_gstreamerException? exceptionInBeforeRetry;
    Object? exceptionInCatch;
    HttpTextResponse? response;
    try {
      response = await flutter_gstreamer.post(
        'https://example.com',
        interceptors: [
          RetryInterceptor(
            beforeRetry: (attempt, request, response, exception) async {
              exceptionInBeforeRetry = exception;
              return null;
            },
          ),
        ],
      );
    } catch (e) {
      exceptionInCatch = e;
    }

    expect(response, null);
    expect(requestCount, 2);
    expect(
      (exceptionInBeforeRetry as flutter_gstreamerUnknownException).message,
      'Failed 111',
    );
    expect(
      (exceptionInCatch as flutter_gstreamerUnknownException).message,
      'Failed 111',
    );
  });

  test('Should retry twice', () async {
    int requestCount = 0;
    mockApi.mockCustomResponse(
      body: 'Retried!',
      onAnswer: (_) {
        requestCount++;
        if (requestCount <= 2) {
          throw const rust_error
              .flutter_gstreamerError_flutter_gstreamerUnknownError(
              'Failed 456');
        }
      },
    );

    flutter_gstreamerException? exceptionInBeforeRetry;
    final response = await flutter_gstreamer.post(
      'https://example.com',
      interceptors: [
        RetryInterceptor(
          maxRetries: 2,
          beforeRetry: (attempt, request, response, exception) async {
            exceptionInBeforeRetry = exception;
            return null;
          },
        ),
      ],
    );

    expect(response.body, 'Retried!');
    expect(requestCount, 3);
    expect(
      (exceptionInBeforeRetry as flutter_gstreamerUnknownException).message,
      'Failed 456',
    );
  });

  test('Should respect shouldRetry condition', () async {
    int requestCount = 0;
    mockApi.mockCustomResponse(
      body: 'Retried!',
      onAnswer: (_) {
        requestCount++;
        if (requestCount <= 3) {
          final statusCode = switch (requestCount) {
            1 => 400,
            2 => 401,
            3 => 403,
            _ => 999, // not reached
          };
          throw rust_error
              .flutter_gstreamerError_flutter_gstreamerStatusCodeError(
            statusCode,
            [],
            const rust_http.HttpResponseBody_Text(''),
          );
        }
      },
    );

    final observedExceptionsInInterceptor =
        <flutter_gstreamerStatusCodeException>[];

    final retry = RetryInterceptor(
      maxRetries: 99,
      shouldRetry: (response, exception) {
        if (exception is flutter_gstreamerStatusCodeException) {
          observedExceptionsInInterceptor.add(exception);
          return exception.statusCode == 403;
        }

        return false;
      },
    );

    Object? exceptionInCatch;
    HttpTextResponse? res;

    try {
      res = await flutter_gstreamer
          .post('https://example.com', interceptors: [retry]);
    } catch (e) {
      exceptionInCatch = e;
    }

    expect(res?.body, null);
    expect(requestCount, 1);
    expect(
      (exceptionInCatch as flutter_gstreamerStatusCodeException).statusCode,
      400,
    );

    try {
      res = await flutter_gstreamer
          .post('https://example.com', interceptors: [retry]);
    } catch (e) {
      exceptionInCatch = e;
    }

    expect(res?.body, null);
    expect(requestCount, 2);
    expect(
      exceptionInCatch,
      isA<flutter_gstreamerStatusCodeException>().having(
        (e) => e.statusCode,
        'statusCode',
        401,
      ),
    );

    exceptionInCatch = null;

    try {
      res = await flutter_gstreamer
          .post('https://example.com', interceptors: [retry]);
    } catch (e) {
      exceptionInCatch = e;
    }

    expect(res?.body, 'Retried!');
    expect(requestCount, 4);
    expect(exceptionInCatch, null);
    expect(
      observedExceptionsInInterceptor.map((e) => e.statusCode),
      [400, 401, 403],
    );
  });
}