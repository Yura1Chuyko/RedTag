public with sharing class CurrencyConverterService {
    static Credentials__mdt fixerCredentials = [SELECT API_Key__c, API_URL__c FROM Credentials__mdt WHERE DeveloperName = 'Fixer'];

    private static final String FIXER_API_KEY = fixerCredentials.API_Key__c;
    private static final String FIXER_API_URL = fixerCredentials.API_URL__c;

    @AuraEnabled(cacheable=true)
    public static Decimal convertCurrency(String fromCurrency, String toCurrency, Decimal amount) {
        if (String.isBlank(fromCurrency) || String.isBlank(toCurrency) || amount == null) {
            throw new IllegalArgumentException('Invalid parameters provided for currency conversion.');
        }

        // Construct the endpoint URL with the API key and required parameters
        String url = FIXER_API_URL + '?access_key=' + FIXER_API_KEY;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            // Check for valid response structure and rates
            if (jsonResponse.containsKey('rates')) {
                Map<String, Object> rates = (Map<String, Object>) jsonResponse.get('rates');

                // Ensure both currencies are available in rates
                if (rates.containsKey(fromCurrency) && rates.containsKey(toCurrency)) {
                    Decimal fromRate = (Decimal) rates.get(fromCurrency);
                    Decimal toRate = (Decimal) rates.get(toCurrency);

                    // Perform conversion calculation
                    Decimal convertedAmount = (amount / fromRate) * toRate;
                    return convertedAmount;
                } else {
                    throw new CalloutException('Conversion rate not found for specified currencies.');
                }
            } else {
                throw new CalloutException('Invalid response structure from Fixer.io API.');
            }
        } else {
            throw new CalloutException('Failed to call Fixer.io API. Status code: ' + response.getStatusCode());
        }
    }
}
