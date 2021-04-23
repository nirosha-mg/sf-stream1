({
    getCourserun: function(component,event){
       // alert('recordId'+component.get("v.recordId"));
        var getCourseRunRecord = component.get('c.getCourseRunRecordPE');
        getCourseRunRecord.setParams({courseRunId: component.get("v.recordId")});
        getCourseRunRecord.setCallback(this, function(response) { 
            if(response.getState() === "SUCCESS") { 
                var courseRunRec = response.getReturnValue();
                console.log(courseRunRec )
                console.log('courseRunRec id  -> '+  courseRunRec.Id )
                console.log('Course_Run_Code__c  -> '+  courseRunRec.Course_Run_Code__c )
                
                
                component.set("v.CourseId",courseRunRec.Course__c);
                component.set("v.courseRunStartDate",courseRunRec.Start_Date__c);
                component.set("v.courserunId",courseRunRec.Id);
                component.set("v.Dubcourseruncode",courseRunRec.Course_Run_Code__c);
                component.set("v.CourseName",courseRunRec.Certificate_Course_Name__c);
                component.set("v.CourseStartDate",$A.localizationService.formatDate(courseRunRec.Registration_Open_Date__c, "DD MMM YYYY"));
                component.set("v.CourseEndDate",$A.localizationService.formatDate(courseRunRec.Registration_Close_Date__c, "DD MMM YYYY"));
                var regChildRecs = courseRunRec.Course_Registrations__r;
                for(var i=0;i<regChildRecs.length;i++){
                    //   alert(" 88 Checking Record Type "+regChildRecs[i].RecordType.Name.replace(/ /g, "").toUpperCase());
                    if(regChildRecs[i].RecordType.Name.replace(/ /g, "").toUpperCase()=="MASTERCOURSEREGISTRATION" && (courseRunRec.Course_Registrations__r[i].Registration_Status__c==='New' || courseRunRec.Course_Registrations__r[i].Registration_Status__c==='Draft')
                       &&( courseRunRec.Course_Registrations__r[i].Payment_Status__c==="Unpaid" || $A.util.isEmpty(courseRunRec.Course_Registrations__r[i].Payment_Status__c))) {
                       //alert("MasterCoursRegistrationid --> "+regChildRecs[i].Id)
                        component.set("v.MasterCoursRegistrationid",regChildRecs[i].Id);
                    }
                }
            }
        }); 
        $A.enqueueAction(getCourseRunRecord);   
    },
    getContactDetails: function(component,event){
        var getContactRecord = component.get('c.getContactDetails');
        getContactRecord.setParams({userId: component.get('v.searchContactId')});
        getContactRecord.setCallback(this, function(response) { 
            if(response.getState() === "SUCCESS") { 
                var ContactRecord = response.getReturnValue(); 
               /* alert('ContactRecord ---> '+JSON.stringify(ContactRecord));
                alert('ContactId ---> '+ContactRecord.ContactId)
                alert('Account.name ---> '+ContactRecord.Account.Name)
                alert('Contact.name ---> '+ContactRecord.Contact.Name)*/
                component.set('v.ContactId',ContactRecord.ContactId);
                component.set('v.AccountName',ContactRecord.Account.Name);
                component.set('v.ContactName',ContactRecord.Contact.Name);   
            }
        }); 
        $A.enqueueAction(getContactRecord);   
    }
})