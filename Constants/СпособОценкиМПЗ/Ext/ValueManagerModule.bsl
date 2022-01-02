﻿
Процедура ПриЗаписи(Отказ)

	ВидСубконтоПартия = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Партия;
	
	Если Значение = Перечисления.СпособыОценки.ФИФО Тогда
		
		// ФИФО: Установить на счетах 10,08,07 - субконто "Партия"
		
		//ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А1000, ВидСубконтоПартия);
		//ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А0800, ВидСубконтоПартия);
		//ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А0700, ВидСубконтоПартия);
		
		ДобавитьСубконтоНаСчет10(ВидСубконтоПартия);
		
		ПараметрыСеанса.ВедетсяПартионныйУчет = Истина;
		
	ИначеЕсли Значение = Перечисления.СпособыОценки.ПоСредней Тогда
		
		// По средней: Удалить с тех же счетов соответственное субконто
		
		//УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А1000, ВидСубконтоПартия);
		//УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А0800, ВидСубконтоПартия);
		//УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А0700, ВидСубконтоПартия);
		
		УдалитьСубконтоСоСчета10(ВидСубконтоПартия);
		
		ПараметрыСеанса.ВедетсяПартионныйУчет = Ложь;
		
	КонецЕсли; 
	
КонецПроцедуры

Процедура ДобавитьСубконтоНаСчет10(ВидСубконтоПартия)
	
	ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А1010, ВидСубконтоПартия);
	ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А1020, ВидСубконтоПартия);
	ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А1030, ВидСубконтоПартия);
	ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А1040, ВидСубконтоПартия);
	ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А1050, ВидСубконтоПартия);
	ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А1060, ВидСубконтоПартия);
	ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А1080, ВидСубконтоПартия);
	ДобавитьСубконтоНаСчет(ПланыСчетов.Хозрасчетный.А1090, ВидСубконтоПартия);
	
КонецПроцедуры

Процедура УдалитьСубконтоСоСчета10(ВидСубконтоПартия)
	
	УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А1010, ВидСубконтоПартия);
	УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А1020, ВидСубконтоПартия);
	УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А1030, ВидСубконтоПартия);
	УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А1040, ВидСубконтоПартия);
	УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А1050, ВидСубконтоПартия);
	УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А1060, ВидСубконтоПартия);
	УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А1080, ВидСубконтоПартия);
	УдалитьСубконтоСоСчета(ПланыСчетов.Хозрасчетный.А1090, ВидСубконтоПартия);
	
КонецПроцедуры

Процедура ДобавитьСубконтоНаСчет(Счет, ВидСубконто)
	
	Выборка = ПланыСчетов.Хозрасчетный.ВыбратьИерархически(Счет);
    Пока Выборка.Следующий() Цикл
	
		СчетОбъект = Выборка.Ссылка.ПолучитьОбъект();
		СтрокаВида = СчетОбъект.ВидыСубконто.Найти(ВидСубконто);
		Если СтрокаВида = Неопределено Тогда
			НоваяСтрокаВида = СчетОбъект.ВидыСубконто.Добавить();
			НоваяСтрокаВида.ВидСубконто = ВидСубконто;
			НоваяСтрокаВида.Количественный = Истина;
			НоваяСтрокаВида.Суммовой = Истина;
			СчетОбъект.Записать();
		КонецЕсли;	
			
	КонецЦикла; 
	
	СчетОбъект = Счет.ПолучитьОбъект();
	СтрокаВида = СчетОбъект.ВидыСубконто.Найти(ВидСубконто);
	Если СтрокаВида = Неопределено Тогда
		НоваяСтрокаВида = СчетОбъект.ВидыСубконто.Добавить();
		НоваяСтрокаВида.ВидСубконто = ВидСубконто;
		НоваяСтрокаВида.Количественный = Истина;
		НоваяСтрокаВида.Суммовой = Истина;
		СчетОбъект.Записать();
    КонецЕсли;
		
КонецПроцедуры
 
Процедура УдалитьСубконтоСоСчета(Счет, ВидСубконто)

	Выборка = ПланыСчетов.Хозрасчетный.ВыбратьИерархически(Счет);
    Пока Выборка.Следующий() Цикл
	
		СчетОбъект = Выборка.Ссылка.ПолучитьОбъект();
		СтрокаВида = СчетОбъект.ВидыСубконто.Найти(ВидСубконто);
		Если Не СтрокаВида = Неопределено Тогда
			СчетОбъект.ВидыСубконто.Удалить(СтрокаВида);
			СчетОбъект.Записать();
		КонецЕсли; 
	
	КонецЦикла; 
	
	СчетОбъект = Счет.ПолучитьОбъект();
	СтрокаВида = СчетОбъект.ВидыСубконто.Найти(ВидСубконто);
	Если Не СтрокаВида = Неопределено Тогда
		СчетОбъект.ВидыСубконто.Удалить(СтрокаВида);
		СчетОбъект.Записать();
	КонецЕсли; 

КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	ТекущееЗначение = Константы.СпособОценкиМПЗ.Получить();
	Если ТекущееЗначение = Перечисления.СпособыОценки.ФИФО И Значение = Перечисления.СпособыОценки.ПоСредней Тогда
	
		//Если Вопрос("Текущее состояние способа оценки МПЗ настроено на партионный учет. 
		//	|Переключение режима способа оценки на вариант ""По среднему"" приведет к 
		//	|безвозвратной потере данных о партиях МПЗ на соответсвующих счетах.
		//	|Вы хотите продолжить?", РежимДиалогаВопрос.ДаНет) <> КодВозвратаДиалога.Да Тогда
		//	Отказ = Истина
		//КонецЕсли;
	
	КонецЕсли; 
	
КонецПроцедуры
