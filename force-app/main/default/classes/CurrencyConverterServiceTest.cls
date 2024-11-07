@IsTest
public class CurrencyConverterServiceTest {
    
    @IsTest
    static void testConvertCurrency_Success() {
        // Setup mock HTTP response
        Test.setMock(HttpCalloutMock.class, new CurrencyConverterMockSuccess());
        
        // Define parameters
        String fromCurrency = 'USD';
        String toCurrency = 'EUR';
        Decimal amount = 100;
        
        // Call the method
        Decimal result = CurrencyConverterService.convertCurrency(fromCurrency, toCurrency, amount);
        
        // Validate the result
        System.assertNotEquals(null, result, 'Converted amount should not be null');
        System.assert(result > 0, 'Converted amount should be greater than zero');
    }

    @IsTest
    static void testConvertCurrencyAsync_InvalidParams() {
        // Expecting an exception when parameters are invalid
        try {
            CurrencyConverterService.convertCurrency('', 'EUR', 100);
            System.assert(false, 'Expected IllegalArgumentException due to invalid parameters');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Invalid parameters provided for currency conversion.', e.getMessage());
        }
    }

    @IsTest
    static void testConvertCurrencyAsync_ApiFailure() {
        // Setup mock HTTP response for a failed callout
        Test.setMock(HttpCalloutMock.class, new CurrencyConverterMockFailure());
        
        try {
            CurrencyConverterService.convertCurrency('USD', 'EUR', 100);
            System.assert(false, 'Expected CalloutException due to failed API call');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('Failed to call Fixer.io API'), 'Expected failure message due to API failure');
        }
    }
    
    // Mock class for successful callout
    private class CurrencyConverterMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"rates": {"USD": 1.0, "EUR": 0.85}}');
            return res;
        }
    }
    
    // Mock class for API failure response
    private class CurrencyConverterMockFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            return res;
        }
    }
}
