import { LightningElement, api, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';

export default class TaskDatatable extends LightningElement {
    @api tasks;
    @track draftValues = [];
    columns = [
        {
            label: 'Task ID',
            fieldName: 'taskUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'Id' },
                target: '_blank'
            }
        },
        { label: 'Task Subject', fieldName: 'Subject', type: 'picklist', editable: true },
        { label: 'Status', fieldName: 'Status', type: 'picklist', editable: true }, 
        { label:'Due Date', fieldName: 'ActivityDate',type: 'date', editable: true}
    ];
    get data() {
        return this.tasks.map(task => ({
            ...task,
            taskUrl: `/lightning/r/Task/${task.Id}/view` 
        }));
    }

    handleSave(event) {
        this.draftValues = event.detail.draftValues;

        const records = this.draftValues.map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        const promises = records.map(recordInput => updateRecord(recordInput));

        Promise.all(promises)
            .then(() => {
                this.draftValues = [];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Tasks updated successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating or reloading records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}
