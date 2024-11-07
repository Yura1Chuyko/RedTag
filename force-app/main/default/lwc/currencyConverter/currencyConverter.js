import { LightningElement, api, track, wire } from 'lwc';
import getCurrencyPicklistValues from '@salesforce/apex/CurrencyConverterController.getTargetCurrencies';
import getCurrencyFields from '@salesforce/apex/CurrencyConverterController.getCurrencyFields';
import getCurrencyFieldValue from '@salesforce/apex/CurrencyConverterController.getCurrencyFieldValue'; 
import getCurrentUserCurrencyIsoCode from '@salesforce/apex/CurrencyConverterController.getCurrentUserCurrencyIsoCode';
import convertCurrency from '@salesforce/apex/CurrencyConverterService.convertCurrency'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CurrencyConverter extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track currencyFields = [];
    @track picklistValues = [];
    @track selectedCurrencyField;
    @track selectedCurrencyCode;
    @track convertedValue;
    amountToConvert; // Value of selected currency field
    sourceCurrency = ''; // User`s currency ISO code


    // Retrieve currency fields dynamically
    @wire(getCurrencyFields,{objectName: '$objectApiName'})
    wiredCurrencyFields({ error, data }) {
        if (data) {
            this.currencyFields = data.map(field => ({ label: field, value: field }));
            console.log('recordId: ' + this.recordId);
            console.log('objectApiName: ' + this.objectApiName);
        } else if (error) {
            this.showToast('Error', 'Failed to load currency fields', 'error');
        }
    }

    // Retrieve picklist values for CurrencyCode__c
    @wire(getCurrencyPicklistValues)
    wiredCurrencyPicklistValues({ error, data }) {
        if (data) {
            this.picklistValues = data.map(code => ({ label: code, value: code }));
        } else if (error) {
            this.showToast('Error', 'Failed to load currency codes', 'error');
        }
    }
    connectedCallback() {
        getCurrentUserCurrencyIsoCode()
            .then(result => {
                this.sourceCurrency = result;
            })
            .catch(error => {
                this.showToast('Error', 'Failed to load user currency', 'error');
            });
    }
    fetchCurrencyFieldValue() {
        if (!this.selectedCurrencyField) {
            this.showToast('Error', 'Please select a currency field.', 'error');
            return;
        }
        getCurrencyFieldValue({ 
            objectName: this.objectApiName, 
            recordId: this.recordId, 
            currencyFieldName: this.selectedCurrencyField 
        })
            .then(amount => {
                this.amountToConvert = amount;
                this.showToast('Success', 'Currency field value retrieved successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Failed to retrieve currency field value', 'error');
            });
    }

    handleFieldChange(event) {
        this.selectedCurrencyField = event.target.value;
        this.fetchCurrencyFieldValue();
    }

    handleCurrencyCodeChange(event) {
        this.selectedCurrencyCode = event.target.value;
    }
    handleConvert() {
        if (!this.amountToConvert || !this.selectedCurrencyCode) {
            this.showToast('Error', 'Please complete field selections before conversion.', 'error');
            return;
        }

        convertCurrency({ 
            fromCurrency: this.sourceCurrency, 
            toCurrency: this.selectedCurrencyCode, 
            amount: this.amountToConvert 
        })
            .then(result => {
                this.convertedValue = result;
                this.showToast('Success', 'Currency converted successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Currency conversion failed', 'error');
            });
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}
