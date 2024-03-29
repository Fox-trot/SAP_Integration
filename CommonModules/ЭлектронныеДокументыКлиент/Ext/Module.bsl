﻿////////////////////////////////////////////////////////////////////////////////
// ЭлектронныеДокументыКлиент: механизм обмена электронными документами.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

////////////////////////////////////////////////////////////////////////////////
// Работа с электронными документами

// Процедура создает, подписывает и отправляет электронный документ.
//
// Параметры:
//  ПараметрКоманды - СсылкаНаОбъект - ссылка на объект ИБ, электронные документы которого надо отправить,
//  ЭД - электронный документ, который надо подписать, отправить.
//
Процедура venkonСформироватьПодписатьОтправитьЭД(ПараметрКоманды = Неопределено, Знач МассивСсылок = Неопределено, ЭД = Неопределено, ДопПараметры = Неопределено) Экспорт
	
	Если ПараметрКоманды <> Неопределено Тогда
		
		МассивСсылок = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМассивПараметров(ПараметрКоманды);
		
	Иначе
		
		Если МассивСсылок = Неопределено Тогда
			
			Если ЭД = Неопределено Тогда
				Возврат;
			Иначе
				МассивСсылок = Новый Массив;
			КонецЕсли;
			
		ИначеЕсли Не ТипЗнч(МассивСсылок) = Тип("Массив") Тогда
			
			НовыйМассив = Новый Массив;
			НовыйМассив.Добавить(МассивСсылок);
			
			МассивСсылок = НовыйМассив;
			
		КонецЕсли;
		
	КонецЕсли;

	ЭлектронныеДокументыСлужебныйКлиент.ОбработатьЭД(МассивСсылок, "СформироватьУтвердитьПодписатьОтправить", ДопПараметры, ЭД);
	
КонецПроцедуры

Процедура venkonОтказать(МассивСсылок, ЭД = Неопределено) Экспорт
	
	Если МассивСсылок = Неопределено Тогда
		Если ЭД = Неопределено Тогда
			Возврат;
		Иначе
			МассивСсылок = Новый Массив;
		КонецЕсли;
	КонецЕсли;
	
	ЭлектронныеДокументыСлужебныйКлиент.ОбработатьЭД(МассивСсылок, "Отказать", , ЭД);
	
КонецПроцедуры

Процедура venkonУдалить(МассивСсылок, ЭД = Неопределено) Экспорт
	
	Если МассивСсылок = Неопределено Тогда
		Если ЭД = Неопределено Тогда
			Возврат;
		Иначе
			МассивСсылок = Новый Массив;
		КонецЕсли;
	КонецЕсли;
	
	ЭлектронныеДокументыСлужебныйКлиент.ОбработатьЭД(МассивСсылок, "Удалить", , ЭД);
	
КонецПроцедуры

// Запускает мастер-помощник по подключению организации к сервису Venkon ЭДО.
//
Процедура ПомощникПодключенияКСервисуVenkonЭДО() Экспорт
	
	ОткрытьФорму("Справочник.ПрофилиНастроекЭДО.Форма.ПомощникПодключенияЭДО");
	
КонецПроцедуры

// Запускает обработку "Текущие дела по ЭДО".
//
Процедура ОткрытьТекущиеДелаЭДО() Экспорт
	
	ОткрытьФорму("Обработка.ТекущиеДелаПоЭДО.Форма");
	
КонецПроцедуры

// Открывается форма списка только с закладкой Настройки ЭДО с контрагентами.
//
Процедура ОткрытьФормуПрофилейЭДО() Экспорт
	
	ОткрытьФорму("Справочник.ПрофилиНастроекЭДО.Форма.ФормаСписка");
	
КонецПроцедуры

// Открывает актуальный ЭД по документу ИБ
//
// Параметры:
//  ПараметрКоманды - ссылка на документ ИБ;
//  Источник - управляемая форма;
//  ПараметрыОткрытия - структура, дополнительные параметры просмотра.
//
Процедура ОткрытьАктуальныйЭД(ПараметрКоманды, Источник = Неопределено, ПараметрыОткрытия = Неопределено) Экспорт
	
	ОчиститьСообщения();
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Если НЕ ЭлектронныеДокументыСлужебныйВызовСервера.ЕстьПравоЧтенияЭД() Тогда
			Возврат;
		КонецЕсли;
	#КонецЕсли
	
	МассивСсылок = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМассивПараметров(ПараметрКоманды);
	Если МассивСсылок = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СоответствиеВладельцевИЭД = ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьСоответствиеВладельцевИЭД(МассивСсылок);
	Для Каждого ТекЭл Из МассивСсылок Цикл
		
		СсылкаНаЭД = СоответствиеВладельцевИЭД.Получить(ТекЭл);
		Если ЗначениеЗаполнено(СсылкаНаЭД) Тогда
			Если ТипЗнч(ПараметрыОткрытия) = Тип("ПараметрыВыполненияКоманды") Тогда
				
				ЭлектронныеДокументыСлужебныйКлиент.ОткрытьЭДДляПросмотра(СсылкаНаЭД,
																		  ПараметрыОткрытия,
																		  ПараметрыОткрытия.Источник,
																		  Истина);
			Иначе
				ЭлектронныеДокументыСлужебныйКлиент.ОткрытьЭДДляПросмотра(СсылкаНаЭД, , Источник, Истина);
			КонецЕсли;
			
		Иначе
			ТекстШаблона = НСтр("ru = '%1. Актуальный электронный документ не найден!'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстШаблона, ТекЭл);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Команды работы с файлами

// Сохраняет текущую версию файла в выбранный каталог на жестком или сетевом диске.
Процедура СохранитьКак(ДанныеФайла) Экспорт
	
	ЭлектронныеДокументыСлужебныйКлиент.СохранитьКак(ДанныеФайла);
	
КонецПроцедуры

