﻿Перем мВалютаРегламентированногоУчета Экспорт;
Перем мИспользоватьХарактеристики Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ 

#Если Клиент Тогда

// Функция формирует табличный документ с печатной формой накладной,
// разработанной методистами
//
// Возвращаемое значение:
//  Табличный документ - печатная форма накладной
//
Функция ПечатьДокумента()

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.Ссылка);
	Запрос.Текст ="
	|ВЫБРАТЬ
	|	Номер,
	|	Дата,
	|	Ответственный.Представление КАК ОтветственныйПредставление
	|ИЗ
	|	Документ.УстановкаЦенНоменклатуры КАК УстановкаЦенНоменклатуры
	|
	|ГДЕ
	|	УстановкаЦенНоменклатуры.Ссылка = &ТекущийДокумент";

	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.Ссылка);

	Запрос.Текст =
	"ВЫБРАТЬ
	|	УстановкаЦенНоменклатуры.НомерСтроки 				     КАК НомерСтроки,
	|	УстановкаЦенНоменклатуры.Номенклатура,
	|	УстановкаЦенНоменклатуры.Номенклатура.НаименованиеПолное КАК Товар,
	|	УстановкаЦенНоменклатуры.Цена,
	|	УстановкаЦенНоменклатуры.Номенклатура.БазоваяЕдиницаИзмерения.Представление  КАК ЕдиницаИзмеренияПредставление,
	|	УстановкаЦенНоменклатуры.Валюта,
	|	УстановкаЦенНоменклатуры.Валюта.Представление            КАК ВалютаПредставление
	|
	|ИЗ
	|	Документ.УстановкаЦенНоменклатуры.Товары КАК УстановкаЦенНоменклатуры
	|
	|ГДЕ
	|	УстановкаЦенНоменклатуры.Ссылка = &ТекущийДокумент
	|
	|УПОРЯДОЧИТЬ ПО
	|	УстановкаЦенНоменклатуры.НомерСтроки
	|";

	ЗапросПоТоварам = Запрос.Выполнить();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_УстановкаЦенНоменклатуры_ИзменениеЦен";

	Макет = ПолучитьМакет("ИзменениеЦен");

	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = СформироватьЗаголовокДокумента(ЭтотОбъект, "Изменение цен номенклатуры");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьШапкаНоменклатура   = Макет.ПолучитьОбласть("ШапкаТаблицы|Номенклатура");
	ОбластьШапкаТипЦен         = Макет.ПолучитьОбласть("ШапкаТаблицы|Цена");
	ОбластьСтрокаНоменклатура  = Макет.ПолучитьОбласть("Строка|Номенклатура");
	ОбластьСтрокаТипЦен        = Макет.ПолучитьОбласть("Строка|Цена");
	ОбластьПодвалНоменклатура  = Макет.ПолучитьОбласть("Подписи|Номенклатура");
	ОбластьПодвалТипЦен        = Макет.ПолучитьОбласть("Подписи|Цена");

	// Выведем шапку
	ТабДокумент.Вывести(ОбластьШапкаНоменклатура);
	
	ОбластьШапкаТипЦен.Параметры.ТипЦен = ТипЦен;
	ТабДокумент.Присоединить(ОбластьШапкаТипЦен);
	
	// Выведем таблицу
	ВыборкаПоСтрокам = ЗапросПоТоварам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаПоСтрокам.Следующий() Цикл
		ОбластьСтрокаНоменклатура.Параметры.Заполнить(ВыборкаПоСтрокам);
		ОбластьСтрокаНоменклатура.Параметры.Товар = ВыборкаПоСтрокам.Товар;
		ТабДокумент.Вывести(ОбластьСтрокаНоменклатура);
		ОбластьСтрокаТипЦен.Параметры.Заполнить(ВыборкаПоСтрокам);
		ТабДокумент.Присоединить(ОбластьСтрокаТипЦен);
	КонецЦикла;

	// Выведем подвал
	ОбластьПодвалНоменклатура.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьПодвалНоменклатура);
	ТабДокумент.Присоединить(ОбластьПодвалТипЦен);

	ТекОбласть = ТабДокумент.Области.ОтветственныйПредставление;

	ОбластьОтветственного = ТабДокумент.Область(ТекОбласть.Низ, 14, ТекОбласть.Низ, Мин(ТабДокумент.ШиринаТаблицы, 29));
	ОбластьОтветственного.Объединить();
	ОбластьОтветственного.ГраницаСнизу            = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная);
	ОбластьОтветственного.ГоризонтальноеПоложение = ГоризонтальноеПоложение.Право;

	Возврат ТабДокумент;

КонецФункции // ПечатьДокумента()

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходмое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	Если ИмяМакета = "ПереченьЦен" Тогда
		// Получить экземпляр документа на печать
		ТабДокумент = ПечатьДокумента();
		
	КонецЕсли;
	
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, СформироватьЗаголовокДокумента(ЭтотОбъект, ЭтотОбъект.Метаданные().Представление()), НепосредственнаяПечать);
	
КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("ПереченьЦен", "Перечень цен");

КонецФункции // ПолучитьСтруктуруПечатныхФорм()


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизтов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверка выполняется по выборке из результата запроса по шапке,
// все проверяемые реквизиты должны быть включены в выборку по шапке.
//
// Параметры: 
//  ВыборкаПоШапкеДокумента	- выборка из результата запроса по шапке документа,
//  Отказ 					- флаг отказа в проведении.
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура();

	// Теперь вызовем общую процедуру проверки.
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строк табличной части "Товары".
//
// Параметры:
// Параметры: 
//  ТаблицаПоТоварам        - таблица значений, содержащая данные для проведения и проверки ТЧ Товары
//  СтруктураШапкиДокумента - структура, содержащая рексвизиты шапки документа и результаты запроса по шапке
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиТовары(ТаблицаПоТоварам, СтруктураШапкиДокумента, Отказ, Заголовок)

	ИмяТабличнойЧасти = "Товары";

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Номенклатура, Валюта");
	
	// Теперь вызовем общую процедуру проверки.
	ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "Товары",СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
// Параметры: 
//  РезультатЗапросаПоТоварам - результат запроса по табличной части "Товары",
//  СтруктураШапкиДокумента   - выборка по результату запроса по шапке документа.
//
// Возвращаемое значение:
//  Сформированная таблиица значений.
//
Функция ПодготовитьТаблицуТоваров(РезультатЗапросаПоТоварам, СтруктураШапкиДокумента)

	ТаблицаТоваров = РезультатЗапросаПоТоварам.Выгрузить();
	
	ТаблицаТоваров.Колонки.Добавить("ТипЦен");
    ТаблицаТоваров.ЗаполнитьЗначения(СтруктураШапкиДокумента.ТипЦен, "ТипЦен");
	
	Возврат ТаблицаТоваров;

КонецФункции // ПодготовитьТаблицуТоваров()

// Выполняет движения по регистрам 
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоТоварам, Отказ, Заголовок)
	
	НаборДвижений   = Движения.ЦеныНоменклатуры;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	// Заполним таблицу движений.
	ЗагрузитьВТаблицуЗначений(ТаблицаПоТоварам, ТаблицаДвижений);
	
	НаборДвижений.мПериод          = Дата;
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	Если Не Отказ Тогда
		Движения.ЦеныНоменклатуры.ВыполнитьДвижения();
	КонецЕсли;

КонецПроцедуры // ДвиженияПоРегистрам

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)
	
КонецПроцедуры // ОбработкаЗаполнения()

// Процедура - обработчик события "ОбработкаПроведения".
//
Процедура ОбработкаПроведения(Отказ, Режим)
 
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);

	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке = СформироватьДеревоПолейЗапросаПоШапке();
	
	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, "");

	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Номенклатура",               "Номенклатура");
	СтруктураПолей.Вставить("Цена",                       "Цена");
	СтруктураПолей.Вставить("Валюта",                     "Валюта");
	СтруктураПолей.Вставить("ЕдиницаИзмерения",           "ЕдиницаИзмерения");

	РезультатЗапросаПоТоварам = СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "Товары", СтруктураПолей);
	ТаблицаПоТоварам          = ПодготовитьТаблицуТоваров(РезультатЗапросаПоТоварам, СтруктураШапкиДокумента);

	Если СтруктураШапкиДокумента.НеПроводитьНулевыеЗначения Тогда
		Сч = 0;
		Пока Сч < ТаблицаПоТоварам.Количество() Цикл
			СтрокаТаблицы = ТаблицаПоТоварам.Получить(Сч);
			Если СтрокаТаблицы.Цена = 0 Тогда
				ТаблицаПоТоварам.Удалить(СтрокаТаблицы);
			Иначе
				Сч = Сч + 1;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	ПроверитьЗаполнениеТабличнойЧастиТовары(ТаблицаПоТоварам, СтруктураШапкиДокумента, Отказ, Заголовок);

	Если Не Отказ Тогда
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоТоварам, Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры	// ОбработкаПроведения

// Процедура - обработчик события "ПередЗаписью".
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Информация = Строка(ТипЦен);

КонецПроцедуры

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
