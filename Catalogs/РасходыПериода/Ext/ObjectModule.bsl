﻿
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	Если Не ЭтоГруппа Тогда
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриУстановкеНовогоКода(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Если не ЭтоГруппа Тогда 
		Если ВозвращатьВНОБДляНалогаНаПрибыль Тогда 
			ПроверяемыеРеквизиты.добавить("ГрафаПриложения1");
		КонецЕсли;	
		
		Если Приложение3 Тогда 
			ПроверяемыеРеквизиты.добавить("ГрафаПриложения3");
		КонецЕсли;
		
		Если Приложение5 Тогда 
			ПроверяемыеРеквизиты.добавить("ГрафаПриложения5");
		КонецЕсли;	
	КонецЕсли;
	
КонецПроцедуры

//Процедура ПриЗаписи(Отказ)
//	ДанныеИзРегистраСведений = РегистрыСведений.ПриложенияКРасчетуНалогаНаПрибыль.СрезПоследних(ТекущаяДата(),новый структура("СтатьяЗатрат",Ссылка));
//	
//	Если ДанныеИзРегистраСведений.Количество()= 0 Тогда
//		Если ВозвращатьВНОБДляНалогаНаПрибыль или Приложение3 или Приложение5 Тогда 
//			НовыйНаборЗаписей = РегистрыСведений.ПриложенияКРасчетуНалогаНаПрибыль.СоздатьНаборЗаписей();
//			НоваяЗаписьНабора = НовыйНаборЗаписей.Добавить();
//			НоваяЗаписьНабора.Период = '1900.01.01';
//			НоваяЗаписьНабора.СтатьяЗатрат = Ссылка ;
//			НоваяЗаписьНабора.НеВычетаемыеРасходыВключаемыеНОБ = ВозвращатьВНОБДляНалогаНаПрибыль;
//			НоваяЗаписьНабора.СтрокаПриложения3 = ГрафаПриложения1;
//			НоваяЗаписьНабора.НеВычетаемыеРасходыВключаемыеНОБОтчетногоПериода = Приложение3;
//			НоваяЗаписьНабора.СтрокаПриложения4 = ГрафаПриложения3;
//			НоваяЗаписьНабора.УменьшениеНОБ  = Приложение5;
//			НоваяЗаписьНабора.СтрокаПриложения7 = ГрафаПриложения5;
//			НовыйНаборЗаписей.Записать();
//		КонецЕсли;
//	КонецЕсли;
//КонецПроцедуры
