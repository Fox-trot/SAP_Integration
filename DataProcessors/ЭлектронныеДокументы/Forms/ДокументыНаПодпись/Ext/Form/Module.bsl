﻿////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

&НаСервере
Процедура ЗаполнитьСписокСертификатовИДокументов(МассивСтруктурСертификатов)
	
	ТаблицаДоступныхСертификатов = ЭлектронныеДокументыСлужебный.ТаблицаДоступныхДляПодписиСертификатов(МассивСтруктурСертификатов);
	ЗаполнитьСводнуюТаблицу(ТаблицаДоступныхСертификатов);
	ЗаполнитьСписокСертификатов(ТаблицаДоступныхСертификатов);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокСертификатов(ТаблицаДоступныхСертификатов)
	
	ТаблицаСертификатов.Очистить();
	Для Каждого ТекСтрока Из ТаблицаДоступныхСертификатов Цикл
		СтрокаТаблицы = ТаблицаСертификатов.Добавить();
		СтрокаТаблицы.Сертификат = ТекСтрока.Ссылка;
		СтрокаТаблицы.Отпечаток = ТекСтрока.Отпечаток;
		СтрокаТаблицы.ПарольПользователя = ТекСтрока.ПарольПользователя;
		ПараметрыОтбора = Новый Структура("Сертификат", ТекСтрока.Ссылка);
		СтрокаТаблицы.КоличествоДокументов = СводнаяТаблица.НайтиСтроки(ПараметрыОтбора).Количество();
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСводнуюТаблицу(ТаблицаДоступныхСертификатов)
	
	ЗапросПоДокументам = Новый Запрос;
	
	СтруктураДопОтбора = Новый Структура;
	Если ЗначениеЗаполнено(Контрагент) Тогда 
		СтруктураДопОтбора.Вставить("Контрагент", Контрагент);
		ЗапросПоДокументам.УстановитьПараметр("Контрагент", Контрагент);
	КонецЕсли;
	Если ЗначениеЗаполнено(ВидЭД) Тогда 
		СтруктураДопОтбора.Вставить("ВидЭД", ВидЭД);
		ЗапросПоДокументам.УстановитьПараметр("ВидЭД", ВидЭД);
	КонецЕсли;
	Если ЗначениеЗаполнено(НаправлениеЭД) Тогда 
		СтруктураДопОтбора.Вставить("НаправлениеЭД", НаправлениеЭД);
		ЗапросПоДокументам.УстановитьПараметр("НаправлениеЭД", НаправлениеЭД);
	КонецЕсли;
	
	МассивВидовСлужебныхЭД = Новый Массив;
	МассивВидовСлужебныхЭД.Добавить(Перечисления.ВидыЭД.ИзвещениеОПолучении);
	МассивВидовСлужебныхЭД.Добавить(Перечисления.ВидыЭД.УведомлениеОбУточнении);
	
	ЗапросПоДокументам.Текст = ЭлектронныеДокументы.ПолучитьТекстЗапросаЭлектронныхДокументовНаПодписи(Ложь, СтруктураДопОтбора);
	ЗапросПоДокументам.УстановитьПараметр("ТекущийПользователь", АвторизованныйПользователь());
	ЗапросПоДокументам.УстановитьПараметр("ВидыЭД", МассивВидовСлужебныхЭД);
	Таблица = ЗапросПоДокументам.Выполнить().Выгрузить();
	
	ЗначениеВРеквизитФормы(Таблица, "СводнаяТаблица");
	
КонецПроцедуры

&НаКлиенте
Процедура ПерезаполнитьТаблицы()
	
	МассивСтруктурСертификатов = Новый Массив;

	ЗаполнитьСписокСертификатовИДокументов(МассивСтруктурСертификатов);
	ЗаполнитьСписокДокументовПоСертификату();
	
КонецПроцедуры

&НаКлиенте
Функция ЕстьДокументыНаПодпись() 
	
	ПроверочныеДанные = ?(Элементы.ТаблицаСертификатов.ТекущиеДанные = Неопределено,
		ТаблицаСертификатов[0], Элементы.ТаблицаСертификатов.ТекущиеДанные);
	
	Если ПроверочныеДанные.КоличествоДокументов = 0 Тогда
		ТекстПредупреждения = НСтр("ru = 'По данному сертификату нет документов на подпись'");
		ПоказатьПредупреждение(, ТекстПредупреждения);
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

&НаКлиенте
Процедура ПерейтиНаСтраницу(КДетализации)
	
	Если КДетализации Тогда
		Элементы.СтраницыАРМ.ТекущаяСтраница = Элементы.СтраницыАРМ.ПодчиненныеЭлементы.СтраницаДетализации;
		Заголовок = НСтр("ru = 'Документы на подпись по сертификату'")+ ": " + СертификатПодписи;
	Иначе
		Элементы.СтраницыАРМ.ТекущаяСтраница = Элементы.СтраницыАРМ.ПодчиненныеЭлементы.СтраницаСводки;
		Заголовок = НСтр("ru = 'Документы на подпись'");
	КонецЕсли;
	
	Элементы.Подписать.Заголовок = Нстр("ru = 'Подписать и отправить отмеченные'");
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокДокументовПоСертификату()
	
	ТаблицаДокументов.Очистить();
	ПараметрыОтбора = Новый Структура("Сертификат", СертификатПодписи);
	СтрокиДокументов = СводнаяТаблица.НайтиСтроки(ПараметрыОтбора);
	
	Для Каждого СтрокаСДокументом Из СтрокиДокументов Цикл
		СтрокаТаблицы = ТаблицаДокументов.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТаблицы, СтрокаСДокументом);
	КонецЦикла;
		
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ДЕЙСТВИЯ КОМАНД ФОРМЫ

&НаКлиенте
Процедура Обновить(Команда)
	
	ПерезаполнитьТаблицы();
	
КонецПроцедуры

&НаКлиенте
Процедура Подписать(Команда)
	
	МассивЭД = Новый Массив;
	Для Каждого ТекСтрока Из ТаблицаДокументов Цикл
		Если ТекСтрока.Выбрать Тогда
			МассивЭД.Добавить(ТекСтрока.ЭлектронныйДокумент);
		КонецЕсли;
	КонецЦикла;
	
	ЭлектронныеДокументыКлиент.venkonСформироватьПодписатьОтправитьЭД(, , МассивЭД);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодписатьВсе(Команда)
	
	Если НЕ ЕстьДокументыНаПодпись() Тогда
		Возврат;
	КонецЕсли;
	
	// По выделенному сертификату найдем все документы на подпись
	СертификатПодписи = ?(Элементы.ТаблицаСертификатов.ТекущиеДанные = Неопределено,
		ТаблицаСертификатов[0].Сертификат, Элементы.ТаблицаСертификатов.ТекущиеДанные.Сертификат);
	
	ПараметрыОтбора = Новый Структура("Сертификат", СертификатПодписи);
	СтрокиДокументов = СводнаяТаблица.НайтиСтроки(ПараметрыОтбора);
	
	МассивДокументовНаПодпись = Новый Массив;
	Для Каждого ЭлементТаблицы Из СтрокиДокументов Цикл
		МассивДокументовНаПодпись.Добавить(ЭлементТаблицы.ЭлектронныйДокумент);
	КонецЦикла;
	
	ЭлектронныеДокументыКлиент.venkonСформироватьПодписатьОтправитьЭД(, , МассивДокументовНаПодпись);
	
КонецПроцедуры

&НаКлиенте
Процедура ВернутьсяКСпискуСертификатов(Команда)
	
	ПерейтиНаСтраницу(Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиКСпискуДокументов(Команда)
	
	СертификатПодписи = ?(Элементы.ТаблицаСертификатов.ТекущиеДанные = Неопределено,
		ТаблицаСертификатов[0].Сертификат, Элементы.ТаблицаСертификатов.ТекущиеДанные.Сертификат);
		
	Если НЕ ЕстьДокументыНаПодпись() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьСписокДокументовПоСертификату();
	ПерейтиНаСтраницу(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтметитьВыделенные(Команда)
	
	МассивСтрок = Элементы.ТаблицаДокументов.ВыделенныеСтроки;
	Для Каждого НомерСтроки Из МассивСтрок Цикл
		СтрокаТаблицы = ТаблицаДокументов.НайтиПоИдентификатору(НомерСтроки);
		Если СтрокаТаблицы <> Неопределено Тогда
			СтрокаТаблицы.Выбрать = Истина;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьОтметкуСоВсехСтрок(Команда)
	
	Для Каждого ТекДокумент Из ТаблицаДокументов Цикл
		Если ТекДокумент.Выбрать Тогда
			ТекДокумент.Выбрать = Ложь;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ПОЛЕЙ ФОРМЫ

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	
	ПерезаполнитьТаблицы();
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаДокументовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ЭлектронныеДокументыСлужебныйКлиент.ОткрытьЭДДляПросмотра(Элементы.ТаблицаДокументов.ТекущиеДанные.ЭлектронныйДокумент);
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСертификатовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СертификатПодписи = Элементы.ТаблицаСертификатов.ТекущиеДанные.Сертификат;
	Если НЕ ЕстьДокументыНаПодпись() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьСписокДокументовПоСертификату();
	ПерейтиНаСтраницу(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ВидЭДПриИзменении(Элемент)
	
	ПерезаполнитьТаблицы();
	
КонецПроцедуры

&НаКлиенте
Процедура НаправлениеЭДПриИзменении(Элемент)
	
	ПерезаполнитьТаблицы();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	МассивСтруктурСертификатов = Новый Массив;
	
	ЗаполнитьСписокСертификатовИДокументов(МассивСтруктурСертификатов);
	
	КоличествоСертификатоа = ТаблицаСертификатов.Количество();
	Если КоличествоСертификатоа = 0 Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ПоказатьПредупреждениеЗавершение", ЭтаФорма);
		ТекстПредупреждения = НСтр("ru = 'Нет сертификатов подписи для пользователя или не настроены правила подписи документов!'"); 
		ПоказатьПредупреждение(ОписаниеОповещения, ТекстПредупреждения);
	КонецЕсли;
	
	Если КоличествоСертификатоа > 1 Тогда
		ПерейтиНаСтраницу(Ложь);
	ИначеЕсли КоличествоСертификатоа = 1 Тогда
		СертификатПодписи = ТаблицаСертификатов[0].Сертификат;
		ЗаполнитьСписокДокументовПоСертификату();
		ПерейтиНаСтраницу(Истина);
		Элементы.ГруппаКнопкиНазад.Видимость = Ложь;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПоказатьПредупреждениеЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Закрыть();
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьЗначениеФункциональнойОпции("ИспользоватьОбменЭД") Тогда
		ТекстСообщения = ЭлектронныеДокументыСлужебныйВызовСервера.ТекстСообщенияОНеобходимостиНастройкиСистемы("РаботаСЭД");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , , , Отказ);
	КонецЕсли;
	
	Если НЕ ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьЗначениеФункциональнойОпции("ИспользоватьЭлектронныеЦифровыеПодписи") Тогда
		ТекстСообщения = ЭлектронныеДокументыСлужебныйВызовСервера.ТекстСообщенияОНеобходимостиНастройкиСистемы("ПодписаниеЭД");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , , , Отказ);
	КонецЕсли;
	
	Элементы.СтраницыАРМ.ОтображениеСтраниц = ОтображениеСтраницФормы.Нет;
	
	АктуальныеВидыЭД = ЭлектронныеДокументыПовтИсп.ПолучитьАктуальныеВидыЭД();
	МассивВычитания = Новый Массив;
	МассивВычитания.Добавить(Перечисления.ВидыЭД.ЗапросВыписки);
	МассивВычитания.Добавить(Перечисления.ВидыЭД.ВыпискаБанка);
	ОбщегоНазначенияКлиентСервер.СократитьМассив(АктуальныеВидыЭД, МассивВычитания);
	Элементы.ВидЭД.СписокВыбора.ЗагрузитьЗначения(АктуальныеВидыЭД);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ОбновитьСостояниеЭД" Тогда
		ПерезаполнитьТаблицы();
	КонецЕсли;
	
КонецПроцедуры
