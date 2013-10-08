var CalendarRowView = Backbone.View.extend({
  className: "calendar-row",
  tagName: 'div',
  
  events: {
    "change .calendar-form-page input" : "updateCalendar",
    "change .calendar-form-page textarea" : "updateCalendar",
    "change .calendar-form-page select" : "updateCalendar",
    "change .host-form-page input" :  "updateHostForm",
    "change .host-form-page textarea" : "updateHostForm",
    "click .form-controls .button" : "executeAction",
    "click .new-category-btn" : "newCategory",
    "click .new-trigger-btn" : "newTrigger",
    "submit #import-events" : "previewImportFile",
  },
  
  initialize: function(o) {
    _.bindAll(this, "render",'remove', "renderThemes");
    revent.themes.bind('refresh', this.renderThemes);
    revent.themes.bind('destroy', this.renderThemes);
    this.submitFlag = false;
  },

  setSubmitFlag: function(){
    this.submitFlag = true;
  },
  
  render: function() {
    jq(this.el).html(JST['calendar_row'](this.getRowData()));
    jq("input.event_start",this.el).datetimepicker({
      changeMonth:true,
      ampm: true
    });
    jq("input.event_end",this.el).datetimepicker({
      changeMonth:true,
      ampm: true
    });
    jq('.calendar-form',this.el).tabs();

    this.renderCategories();
    this.renderEmailTriggers();
    this.renderThemes();

    return this;
  },

  renderCategories: function(){
    new ListView({
      el: jq(".category-list",this.el)[0],
      paginated: false,
      collection: this.model.getCategories(),
      template: 'category',
      row_view: CategoryRowView,
      form_view: CategoryFormView
    }).render();
  },
  
  renderEmailTriggers: function(){
    new ListView({
      el: jq(".email-trigger-list",this.el)[0],
      paginated: false,
      collection: this.model.getEmailTriggers(),
      template: 'email_trigger',
      row_view: EmailTriggerRowView,
      form_view: EmailTriggerFormView
    }).render();
  },

  renderThemes: function(){
    jq(".theme", this.el).html(
      select_field(revent.themes.toSelect(), { name:'theme_id'}, this.model.get('theme_id'))
    );
  },
  
  getRowData: function(){

    return {
      calendar: this.model,
      hostform: this.model.getHostForm(),
      categories: this.model.getCategories()
    };
  },

  newCategory: function(){
    var category = new Category({calendar_id: this.model.get('id')});
    var form = new CategoryFormView({ model:category, template:'category'});
    var calendar = this.model;
    form.render();
    dialog({
      title: 'New Category',
      content: form.el,
      buttons:{
        Cancel: function(){
          return false;
        },
        Save: function(e, done, cancel){
          category.save({},{
            success: function(model,response){
              growl('info','Category Created');
              done();
              calendar.getCategories().add(category);
            },
            error: function(model,response){
              growl('error','Error Creating Category');
              jq('.errors',form.el).html(rails_error(response));
              cancel();
            }
          });
          return true;
        }
      }
    });
  },
  
  newTrigger: function(){
    var trigger = new EmailTrigger({calendar_id: this.model.get('id')});
    var form = new EmailTriggerFormView({ model:trigger, template:'email_trigger'});
    var calendar = this.model;
    form.render();
    dialog({
      title: 'New Email Trigger',
      content: form.el,
      width:'800px',
      buttons:{
        Cancel: function(){
          return false;
        },
        Save: function(e, done, cancel){
          trigger.save({},{
            success: function(model,response){
              growl('info','Email Trigger Created');
              done();
              calendar.getEmailTriggers().add(trigger);
            },
            error: function(model,response){
              growl('error','Error Creating Email Trigger');
              jq('.errors',form.el).html(rails_error(response));
              cancel();
            }
          });
          return true;
        }
      }
    });
  },

  previewImportFile: function(e){
    if(this.submitFlag){
      //submit the form as normal
      return true;
    }
    
    var self = this;
    var fHandle = e.currentTarget[1].files[0]
    var fr = new FileReader();
    fr.readAsText(fHandle);
    fr.onload = function(e){
      self.buildImportForm(e.target.result);
    }

    //prepare the form for submission
    this.setSubmitFlag();
    $("#import-preview-btn").val('Import');

    return false;
  },

  buildImportForm: function(importStr){
    var $el = $("#importPreviewContainer");
    var previewRows = 5; //number of rows to show in preview
    var events = _.map(importStr.split("\n").slice(0,previewRows), function(row){
      return row.split("\t");
    });
    var headers = events[0];
    $el.html(JST['import_preview']({events: events, headers: headers})); 
  },
  
  updateCalendar: function(e){
    var field = e.target;
    var attr = {};
    if(field.type == 'checkbox'){
      attr[field.name] = field.checked;
    } else {
      attr[field.name] = field.value;
    }
    this.model.set(attr);
  },

  updateHostForm: function(e){
    var field = e.target;
    var attr = {};
    if(field.type == 'checkbox'){
      attr[field.name] = field.checked;
    } else {
      attr[field.name] = field.value;
    }
    this.model.getHostForm().set(attr);
  },
  
  executeAction: function(e){
    var form = this;
    switch(jq(e.target).attr('action')){
      case 'save':
        jq(e.target).addClass('button-loading');
        this.model.save({},{
          success:function(model,response){
            jq(e.target).removeClass('button-loading');
            growl('info','Calendar Saved');
            form.trigger('refresh');
          },
          error: function(model,response){
            jq(e.target).removeClass('button-loading');
            growl('error','Error Saving Calendar');
            jq('.errors',form.el).html(rails_error(response));
          }
        });
        break;
      case 'default':
        jq.ajax({
          url:'/admin/calendars/set_default/'+form.model.id,
          type:'put',
          success: function(data){
            growl('info', form.model.get('permalink')+" set as default calendar");
            revent.calendars.get(data.current_default).set({current:true});
            revent.calendars.get(data.previous_default).set({current:false});
            revent.calendars.trigger('reset');
          },
          error: function(xhr){
            growl('error',xhr.responseText);
          }
        });
        break;
    }
    return false;
  }
});
