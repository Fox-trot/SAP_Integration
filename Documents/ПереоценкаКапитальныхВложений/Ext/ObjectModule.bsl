﻿
Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	ДобавитьПрефиксУзла(Префикс);
	
КонецПроцедуры

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("Печать","Печать");
	
КонецФункции

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	ДвиженияПоБУ(Режим, Отказ, Заголовок,СтруктураШапкиДокумента);
		
КонецПроцедуры

Функция ПечатьДокумента(ИмяМакета)
	ТабДок = Новый ТабличныйДокумент;
	
	Макет = ПолучитьМакет("Макет");
	
	Область = Макет.ПолучитьОбласть("Заголовок");
	Область.Параметры.Номер=ПолучитьНомерНаПечать(ЭтотОбъект);
	Область.Параметры.Дата=Формат(Дата,"ДФ=dd.MM.yyyy");
	Область.Параметры.период=Формат(ПериодПереоценки,"ДФ='гггг"" г"".'");
	ТабДок.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть("Строка");
	
	Для каждого Строка Из КапВложения Цикл
	
		Область.Параметры.Заполнить(Строка);
		ТабДок.Вывести(Область);
	
	КонецЦикла; 
	
	Область = Макет.ПолучитьОбласть("Итог");
	Область.Параметры.Стоимость=КапВложения.Итог("Стоимость");
	Область.Параметры.СтоимостьНовая=КапВложения.Итог("СтоимостьНовая");
	Область.Параметры.РазницаПоПереоценке=КапВложения.Итог("РазницаПоПереоценке");
	ТабДок.Вывести(Область);
	
	ТабДок.ПовторятьПриПечатиСтроки=ТабДок.Область(3,0,3);
	ТабДок.Автомасштаб=истина;
	ТабДок.ФиксацияСверху=3;
	ТабДок.ОриентацияСтраницы=ОриентацияСтраницы.Портрет;
	ТабДок.ТолькоПросмотр = Истина;
	
	Возврат ТабДок;
	
КонецФункции

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	// Получить экземпляр документа на печать
	
	ТабДокумент = ПечатьДокумента(ИмяМакета);
		
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "");
	
КонецПроцедуры // Печать()


Процедура ДвиженияПоБУ(Режим, Отказ, Заголовок,СтруктураШапкиДокумента)
	
	Для Каждого Строка Из КапВложения Цикл
		
		Если Строка.РазницаПоПереоценке <> 0 Тогда
			
			Проводка = Движения.Хозрасчетный.Добавить();
			
			Проводка.Период       = Дата;
			Проводка.Активность   = Истина;
			Проводка.Организация  = Организация;
			Проводка.Содержание   = "";
			//Проводка.НомерЖурнала = НомерЖурнала;
			Проводка.Сумма        = Строка.РазницаПоПереоценке;
			
			
			Проводка.СчетДт = ПланыСчетов.Хозрасчетный.НайтиПоКоду("0810");
			УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 1, Строка.ОбъектСтроительства);
			УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 2, Строка.СтроительныеЗатраты);
			
			Проводка.СчетКт = ПланыСчетов.Хозрасчетный.НайтиПоКоду("8512");
			УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 1, Строка.ОбъектСтроительства);
			УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 2, Строка.СтроительныеЗатраты);
			
		КонецЕсли;
	КонецЦикла;
	
	
	
	
КонецПроцедуры
 
