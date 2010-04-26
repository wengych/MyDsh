package {
import flash.utils.*;
import mx.core.IFlexModuleFactory;
import flash.system.*
import flash.net.registerClassAlias;
import flash.net.getClassByAlias;
import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.messaging.config.ConfigMap;
import mx.messaging.messages.AcknowledgeMessage;
import mx.messaging.messages.AcknowledgeMessageExt;
import mx.messaging.messages.AsyncMessage;
import mx.messaging.messages.AsyncMessageExt;
import mx.messaging.messages.CommandMessage;
import mx.messaging.messages.CommandMessageExt;
import mx.messaging.messages.ErrorMessage;
import mx.messaging.messages.HTTPRequestMessage;
import mx.messaging.messages.MessagePerformanceInfo;
import mx.utils.ObjectProxy;
import mx.effects.EffectManager;
import mx.core.mx_internal;

[Mixin]
public class _main0_FlexInit
{
   public function _main0_FlexInit()
   {
       super();
   }
   public static function init(fbs:IFlexModuleFactory):void
   {
      EffectManager.mx_internal::registerEffectTrigger("addedEffect", "added");
      EffectManager.mx_internal::registerEffectTrigger("creationCompleteEffect", "creationComplete");
      EffectManager.mx_internal::registerEffectTrigger("focusInEffect", "focusIn");
      EffectManager.mx_internal::registerEffectTrigger("focusOutEffect", "focusOut");
      EffectManager.mx_internal::registerEffectTrigger("hideEffect", "hide");
      EffectManager.mx_internal::registerEffectTrigger("itemsChangeEffect", "itemsChange");
      EffectManager.mx_internal::registerEffectTrigger("mouseDownEffect", "mouseDown");
      EffectManager.mx_internal::registerEffectTrigger("mouseUpEffect", "mouseUp");
      EffectManager.mx_internal::registerEffectTrigger("moveEffect", "move");
      EffectManager.mx_internal::registerEffectTrigger("removedEffect", "removed");
      EffectManager.mx_internal::registerEffectTrigger("resizeEffect", "resize");
      EffectManager.mx_internal::registerEffectTrigger("resizeEndEffect", "resizeEnd");
      EffectManager.mx_internal::registerEffectTrigger("resizeStartEffect", "resizeStart");
      EffectManager.mx_internal::registerEffectTrigger("rollOutEffect", "rollOut");
      EffectManager.mx_internal::registerEffectTrigger("rollOverEffect", "rollOver");
      EffectManager.mx_internal::registerEffectTrigger("showEffect", "show");
      try {
      if (flash.net.getClassByAlias("flex.messaging.io.ArrayCollection") == null){
          flash.net.registerClassAlias("flex.messaging.io.ArrayCollection", mx.collections.ArrayCollection);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.io.ArrayCollection", mx.collections.ArrayCollection); }
      try {
      if (flash.net.getClassByAlias("flex.messaging.io.ArrayList") == null){
          flash.net.registerClassAlias("flex.messaging.io.ArrayList", mx.collections.ArrayList);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.io.ArrayList", mx.collections.ArrayList); }
      try {
      if (flash.net.getClassByAlias("flex.messaging.config.ConfigMap") == null){
          flash.net.registerClassAlias("flex.messaging.config.ConfigMap", mx.messaging.config.ConfigMap);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.config.ConfigMap", mx.messaging.config.ConfigMap); }
      try {
      if (flash.net.getClassByAlias("flex.messaging.messages.AcknowledgeMessage") == null){
          flash.net.registerClassAlias("flex.messaging.messages.AcknowledgeMessage", mx.messaging.messages.AcknowledgeMessage);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.messages.AcknowledgeMessage", mx.messaging.messages.AcknowledgeMessage); }
      try {
      if (flash.net.getClassByAlias("DSK") == null){
          flash.net.registerClassAlias("DSK", mx.messaging.messages.AcknowledgeMessageExt);}
      } catch (e:Error) {
          flash.net.registerClassAlias("DSK", mx.messaging.messages.AcknowledgeMessageExt); }
      try {
      if (flash.net.getClassByAlias("flex.messaging.messages.AsyncMessage") == null){
          flash.net.registerClassAlias("flex.messaging.messages.AsyncMessage", mx.messaging.messages.AsyncMessage);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.messages.AsyncMessage", mx.messaging.messages.AsyncMessage); }
      try {
      if (flash.net.getClassByAlias("DSA") == null){
          flash.net.registerClassAlias("DSA", mx.messaging.messages.AsyncMessageExt);}
      } catch (e:Error) {
          flash.net.registerClassAlias("DSA", mx.messaging.messages.AsyncMessageExt); }
      try {
      if (flash.net.getClassByAlias("flex.messaging.messages.CommandMessage") == null){
          flash.net.registerClassAlias("flex.messaging.messages.CommandMessage", mx.messaging.messages.CommandMessage);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.messages.CommandMessage", mx.messaging.messages.CommandMessage); }
      try {
      if (flash.net.getClassByAlias("DSC") == null){
          flash.net.registerClassAlias("DSC", mx.messaging.messages.CommandMessageExt);}
      } catch (e:Error) {
          flash.net.registerClassAlias("DSC", mx.messaging.messages.CommandMessageExt); }
      try {
      if (flash.net.getClassByAlias("flex.messaging.messages.ErrorMessage") == null){
          flash.net.registerClassAlias("flex.messaging.messages.ErrorMessage", mx.messaging.messages.ErrorMessage);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.messages.ErrorMessage", mx.messaging.messages.ErrorMessage); }
      try {
      if (flash.net.getClassByAlias("flex.messaging.messages.HTTPMessage") == null){
          flash.net.registerClassAlias("flex.messaging.messages.HTTPMessage", mx.messaging.messages.HTTPRequestMessage);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.messages.HTTPMessage", mx.messaging.messages.HTTPRequestMessage); }
      try {
      if (flash.net.getClassByAlias("flex.messaging.messages.MessagePerformanceInfo") == null){
          flash.net.registerClassAlias("flex.messaging.messages.MessagePerformanceInfo", mx.messaging.messages.MessagePerformanceInfo);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.messages.MessagePerformanceInfo", mx.messaging.messages.MessagePerformanceInfo); }
      try {
      if (flash.net.getClassByAlias("flex.messaging.io.ObjectProxy") == null){
          flash.net.registerClassAlias("flex.messaging.io.ObjectProxy", mx.utils.ObjectProxy);}
      } catch (e:Error) {
          flash.net.registerClassAlias("flex.messaging.io.ObjectProxy", mx.utils.ObjectProxy); }
      var styleNames:Array = ["fontWeight", "modalTransparencyBlur", "rollOverColor", "textRollOverColor", "verticalGridLineColor", "backgroundDisabledColor", "textIndent", "barColor", "fontSize", "kerning", "footerColors", "textAlign", "disabledIconColor", "fontStyle", "dropdownBorderColor", "modalTransparencyDuration", "textSelectedColor", "horizontalGridLineColor", "selectionColor", "modalTransparency", "fontGridFitType", "selectionDisabledColor", "disabledColor", "fontAntiAliasType", "modalTransparencyColor", "alternatingItemColors", "leading", "iconColor", "dropShadowColor", "themeColor", "indicatorGap", "letterSpacing", "fontFamily", "color", "fontThickness", "labelWidth", "errorColor", "headerColors", "fontSharpness", "textDecoration"];

      import mx.styles.StyleManager;

      for (var i:int = 0; i < styleNames.length; i++)
      {
         StyleManager.registerInheritingStyle(styleNames[i]);
      }
   }
}  // FlexInit
}  // package
