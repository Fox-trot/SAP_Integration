﻿
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Элементы.Организация.ТолькоПросмотр = не УчетПоВсемОрганизациям;
	Элементы.Ответственный.ТолькоПросмотр = не ПроцедурыСервера.РольДоступна_Сервер("ПолныеПрава");
	
	УстановитьВидимость();
	РассчитатьИтоги();
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Объект.Ссылка.Пустая() Тогда
		
		ПроцедурыСервера.ЗаполнитьШапкуДокумента_Сервер(Объект, Объект.Ссылка);
		
	КонецЕсли;
	
	Для Каждого Строка Из Объект.Услуги Цикл
		
		Строка.Всего=Строка.Сумма+Строка.СуммаНДС;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьЕдиныйСчетЗатратПриИзменении(Элемент)
	
	УстановитьВидимость();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВидимость()
	
	Элементы.УслугиСчетЗатрат.Видимость=не Объект.ИспользоватьЕдиныйСчетЗатрат;
	Элементы.УслугиСубконто1.Видимость=не Объект.ИспользоватьЕдиныйСчетЗатрат;
	Элементы.УслугиСубконто2.Видимость=не Объект.ИспользоватьЕдиныйСчетЗатрат;
	Элементы.УслугиСубконто3.Видимость=не Объект.ИспользоватьЕдиныйСчетЗатрат;
	
	Элементы.СтраницаСчетУчетаЗатрат.Видимость=Объект.ИспользоватьЕдиныйСчетЗатрат;
	
КонецПроцедуры

&НаКлиенте
Процедура РассчитатьСумму(ТекущиеДанные=Неопределено)
	
	Если ТекущиеДанные=Неопределено Тогда
		ТекущиеДанные=Элементы.Услуги.ТекущиеДанные;
	КонецЕсли;

	Если ТекущиеДанные=Неопределено Тогда
		Возврат;
	КонецЕсли;
	
//	ТекущиеДанные.Сумма=ТекущиеДанные.Количество*ТекущиеДанные.Цена;
	Если Строка(ТекущиеДанные.СтавкаНДС)="20%" Тогда
		ТекущиеДанные.СуммаНДС=ТекущиеДанные.Сумма*0.2;
	Иначе
		ТекущиеДанные.СуммаНДС=0;
	КонецЕсли;	
	ТекущиеДанные.Всего=ТекущиеДанные.Сумма+ТекущиеДанные.СуммаНДС;
	
	
КонецПроцедуры

&НаКлиенте
Процедура УслугиПриИзменении(Элемент)
	
	РассчитатьСумму();
	РассчитатьИтоги();
	
КонецПроцедуры

&НаКлиенте
Процедура РассчитатьИтоги()
	
	Всего=Объект.Услуги.Итог("Сумма")+Объект.Услуги.Итог("СуммаНДС");
	СуммаНДС=Объект.Услуги.Итог("СуммаНДС");
	
КонецПроцедуры



