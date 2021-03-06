/*
Class: TabsTransformer
    Transform <select> control into <ol> list.

Arguments:
    el - the $(element) to apply the transformation to.
    options - optional. The options object.

Options:
    classes - optional, css classes to be set to tabs
      * list - class for the whole <ol> element
      * selected - class for selected <li>
      * disabled - class for disabled <li>
    callback - optional, callback function to run, when user clicks the tab
*/

var TabsTransformer = new Class({
    
    Implements: Options,
    
    options: {
        classes: {
            list: "tabs",
            selected: "selected",
            disabled: "disabled"
        },
        callback: null,
        "default": null
    },
    
    initialize: function(element, options){
        this.setOptions(options);
        this.element = $(element);
        
        if (!this.element){
            var valid = false;
        } else if (this.element.match("select")){
            var valid = true;
            this.bound = true;
        } else if (this.element.match("ol")){
            var valid = true;
            this.bound = false;
        } else {
            var valid = false;
        }
        
        if (valid){
            if (this.bound){
                this.list = new Element("ol").injectAfter(this.element);
                
                if (this.element.disabled) {
                    this.list.addClass(this.options.classes.disabled);
                }
                
                this.element.style.display = "none";
            } else {
                this.list = this.element;
            }
                
            if (this.options.classes.list) {
                this.list.addClass(this.options.classes.list);
            }
            
            this.tabs = this.element.getChildren().map(function(element){
                if (this.bound){
                    var tab = new Element("li").adopt(new Element("span", {html: element.get("html")})).injectInside(this.list);
                    
                    if (element.className){
                        tab.addClass(element.className);
                    }
                    
                    if (this.element.value == element.value){
                        tab.addClass(this.options.classes.selected);
                    }
                    
                    return tab.store("id", element.get("value"));
                } else {
                    if (element.getFirst().match("a")){
                        new Element("span", {text: element.getFirst().get("text")}).replaces(element.getFirst());
                    }
                    return element.store("id", element.id);
                }
            }, this);
            
            var selected;
            if (!this.element.hasClass(this.options.classes.disabled)){
                this.tabs.each(function(tab){
                    tab.store("selector", this.onSelect.bindWithEvent(this, tab));
                    
                    if (!this.list.hasClass(this.options.classes.disabled)){
                        tab.addEvent("mousedown", tab.retrieve("selector"));
                    }
                }, this);
            }
            
            if (!this.list.hasClass(this.options.classes.disabled)){
                this.select(this.options["default"] || this.tabs.filter(function(tab){ return tab.hasClass(this.options.classes.selected); }, this)[0].retrieve("id"));
            }
        }
    },
    
    attach: function(){
        this.tabs.each(function(tab){
            tab.addEvent("mousedown", tab.retrieve("selector"));
        });
        return this;
    },
    
    detach: function(){
        this.tabs.each(function(tab){
            tab.removeEvent("mousedown", tab.retrieve("selector"));
        });
        return this;
    },
    
    enable: function(){
        this.list.removeClass(this.options.classes.disabled);
        return this.attach();
    },
    
    disable: function(){
        this.list.addClass(this.options.classes.disabled);
        return this.detach();
    },
    
    select: function(id){
        for (var tab = 0, len = this.tabs.length; tab < len; tab++){
            if (this.tabs[tab].retrieve("id") == id){
                this.tabs[tab].fireEvent("mousedown");
                break;
            }
        }
        return this;
    },
    
    onSelect: function(event, tab){
        this.tabs.each(function(bat){
            (bat == tab) ? bat.addClass(this.options.classes.selected) : bat.removeClass(this.options.classes.selected);
        }, this);
        
        if (this.bound){
            this.element.getChildren().each(function(option){
                (option.get("value") == tab.retrieve("id")) ? option.set("selected", "selected") : option.removeProperty("selected");
            });
        }
        
        if (this.options.callback){
            this.options.callback.bind(this)(tab.retrieve("id"));
        }
    }
});

/*
Class: Element
    Custom class to allow all of its methods to be used with any DOM element via the dollar function <$>.
*/

Element.implement({

    /*
    Property: makeTabs
        Transforms <select> control into <ol> list.

    Arguments:
        options - see <Tabs> for acceptable options.
    */

    makeTabs: function(options){
        return new TabsTransformer(this, options);
    }
});
