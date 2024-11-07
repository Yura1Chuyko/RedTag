public with sharing class CurrencyConverterService {
    private static final String API_KEY = '3d2ca425e467b79f3b75b56a60cf03f8';
    private static final String FIXER_API_URL = 'http://data.fixer.io/api/convert';

    @AuraEnabled(cacheable=false)
    public static Decimal convertCurrency(String fromCurrency, String toCurrency, Decimal amount) {
        if (String.isBlank(fromCurrency) || String.isBlank(toCurrency) || amount == null) {
            throw new IllegalArgumentException('Invalid parameters provided for currency conversion.');
        }
        String url = FIXER_API_URL + '?access_key=' + API_KEY + '&from=' + fromCurrency + '&to=' + toCurrency + '&amount=' + amount;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if (jsonResponse.containsKey('result')) {
                return (Decimal) jsonResponse.get('result');
            } else {
                throw new CalloutException('Currency conversion failed. Please check your API access or parameters.');
            }
        } else {
            throw new CalloutException('Failed to call Fixer.io API. Status code: ' + response.getStatusCode());
        }
    }
}