import { LightningElement, track, wire } from 'lwc';
import getTasksGroupedByStage from '@salesforce/apex/TaskStageAccordionController.getTasksGroupedByStage';
import updateTasks from '@salesforce/apex/TaskStageAccordionController.updateTasks'; 

export default class ProjectTasksAccordion extends LightningElement {
    @track stagesWithTasks = []; 

    @wire(getTasksGroupedByStage)
    wiredTasks({ error, data }) {
        if (data) {
            this.stagesWithTasks = Object.keys(data).map(stage => ({
                stage,
                tasks: data[stage]
            }));
        } else if (error) {
            console.error(error);
        }
    }

    handleTaskEdit(event) {
        const updatedTasks = event.detail;

        updateTasks({ tasks: updatedTasks })
            .then(() => {
                console.log('Tasks updated successfully');
            })
            .catch(error => {
                console.error('Error updating tasks: ', error);
            });
    }
}
