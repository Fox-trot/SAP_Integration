﻿
////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Организация) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			ЭлектронныеДокументыКлиентСервер.ПолучитьТекстСообщения("Поле", "Заполнение", "Организация"),
			ЭтотОбъект,
			"Организация",
			,
			Отказ);
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
		
	Если ПустаяСтрока(Пароль) Тогда
		Пароль = Справочники.ПрофилиНастроекЭДО.СгенерироватьНовыйПароль(20);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

// Только для внутреннего использования
Функция ПрофильНастроекЭДОУникален() Экспорт
	
	Если ПометкаУдаления Тогда
		Возврат Истина;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	ПрофилиНастроекЭДО.Ссылка КАК ПрофильНастроекЭДО
	|ИЗ
	|	Справочник.ПрофилиНастроекЭДО КАК ПрофилиНастроекЭДО
	|ГДЕ
	|	ПрофилиНастроекЭДО.ссылка <> &Ссылка
	|			И ПрофилиНастроекЭДО.Организация = &Организация
	|					И ПрофилиНастроекЭДО.ИдентификаторОрганизации = &ИдентификаторОрганизации
	|	И Не ПрофилиНастроекЭДО.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("ИдентификаторОрганизации", ЭтотОбъект.ИдентификаторОрганизации);
	Запрос.УстановитьПараметр("Организация",              ЭтотОбъект.Организация);
	Запрос.УстановитьПараметр("Ссылка",                   ЭтотОбъект.Ссылка);
	Результат = Запрос.Выполнить();
	ТекущийПрофильНастроекУникален = Результат.Пустой();
	
	Если Не ТекущийПрофильНастроекУникален Тогда
		ШаблонСообщения = НСтр("ru = 'В информационной базе уже существует профиль настроек с реквизитами:
		|Организация - %1;
		|Идентификатор организации - %2;
		|Способ обмена - %3;'");
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
														ШаблонСообщения,
														ЭтотОбъект.Организация,
														ЭтотОбъект.ИдентификаторОрганизации);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
	КонецЕсли;
	
	Возврат ТекущийПрофильНастроекУникален;
	
КонецФункции

