﻿
Перем мТекстЗапросаОтборНоменклатурыПоРодителю;

#Если Клиент Тогда

// Функция формирует список имен параметров для подстановки значений в запросы
//
// Параметры
//  ИмяПодбора - строка, имя подбора, по которому определяется запрос
//
// Возвращаемое значение:
//   СписокЗначений
//
Функция ПолучитьСписокПараметровЗапроса(ИмяПодбора) Экспорт

	СписокЗначенийВозврата = Новый СписокЗначений;

	Если ИмяПодбора = "ОстаткиИЦеныНоменклатуры"
	 ИЛИ ИмяПодбора = "ОстаткиИПлановаяСебестоимость" Тогда

		СписокЗначенийВозврата.Добавить("ТипЦен");
		СписокЗначенийВозврата.Добавить("Организация");
		СписокЗначенийВозврата.Добавить("Склад");

	ИначеЕсли ИмяПодбора = "ОстаткиУКомиссионеров"
		  ИЛИ ИмяПодбора = "ОстаткиТоваровКомитентов" Тогда

		СписокЗначенийВозврата.Добавить("Организация");
		СписокЗначенийВозврата.Добавить("ТипЦен");
		СписокЗначенийВозврата.Добавить("Контрагент");
		СписокЗначенийВозврата.Добавить("ДоговорКонтрагента");

	ИначеЕсли ИмяПодбора = "ОстаткиНоменклатуры" Тогда

		СписокЗначенийВозврата.Добавить("Организация");
		СписокЗначенийВозврата.Добавить("Склад");
		//СписокЗначенийВозврата.Добавить("Цена");

	ИначеЕсли ИмяПодбора = "ОстаткиНеавтоматизированнаяТорговаяТочка" Тогда

		СписокЗначенийВозврата.Добавить("Склад");
		СписокЗначенийВозврата.Добавить("Организация");

	ИначеЕсли ИмяПодбора = "ЦеныНоменклатуры"
		  ИЛИ ИмяПодбора = "ЦеныУслуг"
		  ИЛИ ИмяПодбора = "Услуги" Тогда

		СписокЗначенийВозврата.Добавить("Организация");
		//СписокЗначенийВозврата.Добавить("ТипЦен");

	КонецЕсли;

	Возврат СписокЗначенийВозврата;

КонецФункции

// Функция формирует текст запроса по ИмяПодбора = "РасходОстаткиИЦеныНоменклатуры" для заполнения табличной части
//
// Возвращаемое значение:
//   Текст запроса
//
Функция ЗапросОстаткиИЦеныНоменклатуры(ФильтрПоСубконто, Условие, ФильтрПоСчету = "")

	ТекстЗапроса = "
	|ВЫБРАТЬ
	|	Подбор.Код                                      КАК Код,
	|	Подбор.ЭтоГруппа                                КАК ЭтоГруппа,
	|	Подбор.ПометкаУдаления                          КАК ПометкаУдаления,
	|	Подбор.Услуга                                   КАК Услуга,
	|	Подбор.Номенклатура                             КАК Номенклатура,
	|	Подбор.Родитель                                 КАК Родитель,
	|	Подбор.КоличествоОстатокОрганизации             КАК КоличествоОстатокОрганизации,
	|	Подбор.Цена                                     КАК Цена,
	|	Подбор.ЕдиницаИзмерения                         КАК ЕдиницаИзмерения,
	|	Подбор.Валюта                                   КАК Валюта,
	|	Подбор.Номенклатура.Представление               КАК ПредставлениеНоменклатура,
	|	Подбор.ЕдиницаИзмерения.НаименованиеПолное      КАК ПредставлениеЕдиницаИзмерения,
	|	Подбор.Валюта.Представление                     КАК ПредставлениеВалюта,
	|	ВЫБОР
	|		КОГДА Подбор.ЭтоГруппа ТОГДА ""Группа""
	|		ИНАЧЕ Подбор.Номенклатура.НоменклатурнаяГруппа.Представление
	|	КОНЕЦ                                           КАК ПредставлениеНоменклатурнаяГруппа,
	|	Ложь                                            КАК ПереходитьВверх
	|ИЗ
	|
	|(
	|ВЫБРАТЬ
	|	СправочникНоменклатура.Код                               КАК Код,
	|	СправочникНоменклатура.ЭтоГруппа                         КАК ЭтоГруппа,
	|	СправочникНоменклатура.ПометкаУдаления                   КАК ПометкаУдаления,
	|	СправочникНоменклатура.Услуга                            КАК Услуга,
	|	СправочникНоменклатура.Ссылка                            КАК Номенклатура,
	|	СправочникНоменклатура.Родитель                          КАК Родитель,
	|	СУММА(Остатки.КоличествоОстатокОрганизации)              КАК КоличествоОстатокОрганизации,
	|	МАКСИМУМ(ЦеныСрезПоследних.Цена) КАК Цена,
	|	СправочникНоменклатура.БазоваяЕдиницаИзмерения   КАК ЕдиницаИзмерения,
	|	МАКСИМУМ(ЦеныСрезПоследних.Валюта) 				 КАК Валюта
	|ИЗ
	|	Справочник.Номенклатура КАК СправочникНоменклатура
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&ДатаРегистраСведений, " + мТекстЗапросаОтборНоменклатурыПоРодителю + " И ТипЦен = &ТипЦен) КАК ЦеныСрезПоследних
	|ПО
	|	ЦеныСрезПоследних.Номенклатура = СправочникНоменклатура.Ссылка
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	(
	|	ВЫБРАТЬ
	|		ХозрасчетныйОстатки.Субконто1 КАК Номенклатура,
	|		СУММА(ВЫБОР КОГДА ХозрасчетныйОстатки.КоличествоОстатокДт ЕСТЬ NULL ТОГДА 0 ИНАЧЕ ХозрасчетныйОстатки.КоличествоОстатокДт КОНЕЦ
	|				- ВЫБОР КОГДА ХозрасчетныйОстатки.КоличествоОстатокКт ЕСТЬ NULL ТОГДА 0 ИНАЧЕ ХозрасчетныйОстатки.КоличествоОстатокКт КОНЕЦ) КАК КоличествоОстатокОрганизации
	|	ИЗ
	|		РегистрБухгалтерии.Хозрасчетный.Остатки(&Дата, " + ФильтрПоСчету + ", &ВидыСубконто, " + Условие + ФильтрПоСубконто + ") КАК ХозрасчетныйОстатки
	|   	
	|	СГРУППИРОВАТЬ ПО
	|		ХозрасчетныйОстатки.Субконто1
	|
	|	) КАК Остатки
	|
	|ПО
	|	Остатки.Номенклатура = СправочникНоменклатура.Ссылка
	|
	|ГДЕ
	|	СправочникНоменклатура.Родитель = &Родитель
	|
	|СГРУППИРОВАТЬ ПО
	|	СправочникНоменклатура.Родитель,
	|	СправочникНоменклатура.Ссылка
	|
	|) КАК Подбор
	|
	|УПОРЯДОЧИТЬ ПО
	|	Подбор.ЭтоГруппа УБЫВ,
	|	Подбор.Номенклатура.Наименование
	|";

	Возврат ТекстЗапроса;
	
КонецФункции // ЗапросРасходОстаткиИЦеныНоменклатуры()

// Функция формирует текст запроса по ИмяПодбора = "ОстаткиНоменклатуры" для заполнения табличной части
//
// Возвращаемое значение:
//   Текст запроса
//
Функция ЗапросОстаткиНоменклатуры(ФильтрПоСубконто, Условие, ФильтрПоСчету = "")

	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	Подбор.Код КАК Код,
	|	Подбор.ЭтоГруппа КАК ЭтоГруппа,
	|	Подбор.ПометкаУдаления КАК ПометкаУдаления,
	|	Подбор.Номенклатура КАК Номенклатура,
	|	Подбор.Родитель КАК Родитель,
	|	Подбор.КоличествоОстатокОрганизации КАК КоличествоОстатокОрганизации,
	|	Подбор.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	Подбор.Номенклатура.Представление КАК ПредставлениеНоменклатура,
	|	Подбор.ЕдиницаИзмерения КАК ПредставлениеЕдиницаИзмерения,
	|	ВЫБОР
	|		КОГДА Подбор.ЭтоГруппа
	|			ТОГДА ""Группа""
	|		ИНАЧЕ Подбор.Номенклатура.НоменклатурнаяГруппа.Представление
	|	КОНЕЦ КАК ПредставлениеНоменклатурнаяГруппа,
	|	ЛОЖЬ КАК ПереходитьВверх,
	|	Подбор.Цена
	|ИЗ
	|	(ВЫБРАТЬ
	|		СправочникНоменклатура.Код КАК Код,
	|		СправочникНоменклатура.ЭтоГруппа КАК ЭтоГруппа,
	|		СправочникНоменклатура.ПометкаУдаления КАК ПометкаУдаления,
	|		СправочникНоменклатура.Ссылка КАК Номенклатура,
	|		СправочникНоменклатура.Родитель КАК Родитель,
	|		СправочникНоменклатура.Цена КАК Цена,
	|		СУММА(Остатки.КоличествоОстатокОрганизации) КАК КоличествоОстатокОрганизации,
	|		СправочникНоменклатура.БазоваяЕдиницаИзмерения КАК ЕдиницаИзмерения
	|	ИЗ
	|		Справочник.Номенклатура КАК СправочникНоменклатура
	|			ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|				ХозрасчетныйОстатки.Субконто1 КАК Номенклатура,
	|				СУММА(ВЫБОР
	|						КОГДА ХозрасчетныйОстатки.КоличествоОстатокДт ЕСТЬ NULL 
	|							ТОГДА 0
	|						ИНАЧЕ ХозрасчетныйОстатки.КоличествоОстатокДт
	|					КОНЕЦ - ВЫБОР
	|						КОГДА ХозрасчетныйОстатки.КоличествоОстатокКт ЕСТЬ NULL 
	|							ТОГДА 0
	|						ИНАЧЕ ХозрасчетныйОстатки.КоличествоОстатокКт
	|					КОНЕЦ) КАК КоличествоОстатокОрганизации
	|			ИЗ
 	|		РегистрБухгалтерии.Хозрасчетный.Остатки(&Дата, " + ФильтрПоСчету + ", &ВидыСубконто, " + Условие +" "+ ФильтрПоСубконто + ") КАК ХозрасчетныйОстатки
	|			
	|			СГРУППИРОВАТЬ ПО
	|				ХозрасчетныйОстатки.Субконто1) КАК Остатки
	|			ПО Остатки.Номенклатура = СправочникНоменклатура.Ссылка
	|	ГДЕ
	|		СправочникНоменклатура.Родитель = &Родитель
	|	
	|	СГРУППИРОВАТЬ ПО
	|		СправочникНоменклатура.Родитель,
	|		СправочникНоменклатура.Ссылка,
	|		СправочникНоменклатура.Код,
	|		СправочникНоменклатура.ЭтоГруппа,
	|		СправочникНоменклатура.ПометкаУдаления,
	|		СправочникНоменклатура.Цена,
	|		СправочникНоменклатура.БазоваяЕдиницаИзмерения) КАК Подбор
	|
	|УПОРЯДОЧИТЬ ПО
	|	ЭтоГруппа УБЫВ,
	|	Подбор.Номенклатура.Наименование";
	 //|				РегистрБухгалтерии.Хозрасчетный.Остатки(&Дата, , &ВидыСубконто, ) КАК ХозрасчетныйОстатки

	Возврат ТекстЗапроса;

КонецФункции // ЗапросОстаткиНоменклатуры()

// Функция формирует текст запроса по ИмяПодбора = "РасходПоЦенамНоменклатуры" для заполнения табличной части
//
// Возвращаемое значение:
//   Текст запроса
//
Функция ЗапросЦеныНоменклатуры()

	ТекстЗапроса = "
	|ВЫБРАТЬ
	|	Подбор.Код                                      КАК Код,
	|	Подбор.ЭтоГруппа                                КАК ЭтоГруппа,
	|	Подбор.ПометкаУдаления                          КАК ПометкаУдаления,
	|	Подбор.Услуга                                   КАК Услуга,
	|	Подбор.Номенклатура                             КАК Номенклатура,
	|	Подбор.Родитель                                 КАК Родитель,
	|	Подбор.Цена                                     КАК Цена,
	|	Подбор.ЕдиницаИзмерения                         КАК ЕдиницаИзмерения,
	|	Подбор.Валюта                                   КАК Валюта,
	|	Подбор.Номенклатура.Представление               КАК ПредставлениеНоменклатура,
	|	Подбор.ЕдиницаИзмерения.НаименованиеПолное      КАК ПредставлениеЕдиницаИзмерения,
	|	Подбор.Валюта.Представление                     КАК ПредставлениеВалюта,
	|	ВЫБОР
	|		КОГДА Подбор.ЭтоГруппа ТОГДА ""Группа""
	|		ИНАЧЕ Подбор.Номенклатура.НоменклатурнаяГруппа.Представление
	|	КОНЕЦ                                           КАК ПредставлениеНоменклатурнаяГруппа,
	|	Ложь                                            КАК ПереходитьВверх
	|ИЗ
	|
	|(
	|ВЫБРАТЬ
	|	СправочникНоменклатура.Код                               КАК Код,
	|	СправочникНоменклатура.ЭтоГруппа                         КАК ЭтоГруппа,
	|	СправочникНоменклатура.ПометкаУдаления                   КАК ПометкаУдаления,
	|	СправочникНоменклатура.Услуга                            КАК Услуга,
	|	СправочникНоменклатура.Ссылка                            КАК Номенклатура,
	|	СправочникНоменклатура.Родитель                          КАК Родитель,
	|	МАКСИМУМ(ЦеныСрезПоследних.Цена) КАК Цена,
	|	СправочникНоменклатура.БазоваяЕдиницаИзмерения   КАК ЕдиницаИзмерения,
	|	МАКСИМУМ(ЦеныСрезПоследних.Валюта) 				 КАК Валюта
	|ИЗ
	|	Справочник.Номенклатура КАК СправочникНоменклатура
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&ДатаРегистраСведений, " + мТекстЗапросаОтборНоменклатурыПоРодителю + " И ТипЦен = &ТипЦен) КАК ЦеныСрезПоследних
	|ПО
	|	ЦеныСрезПоследних.Номенклатура = СправочникНоменклатура.Ссылка
	|
	|ГДЕ
	|	СправочникНоменклатура.Родитель = &Родитель 
	|
	|СГРУППИРОВАТЬ ПО
	|	СправочникНоменклатура.Родитель,
	|	СправочникНоменклатура.Ссылка
	|
	|) КАК Подбор
	|
	|УПОРЯДОЧИТЬ ПО
	|	Подбор.ЭтоГруппа УБЫВ,
	|	Подбор.Номенклатура.Наименование
	|";

	Возврат ТекстЗапроса;

КонецФункции // ЗапросРасходПоЦенамНоменклатуры()

// Функция формирует текст запроса по ИмяПодбора = "РасходУслуги" для заполнения табличной части
//
// Возвращаемое значение:
//   Текст запроса
//
Функция ЗапросУслуги()

	ТекстЗапроса = "
	|ВЫБРАТЬ
	|	Подбор.Код                                      КАК Код,
	|	Подбор.ЭтоГруппа                                КАК ЭтоГруппа,
	|	Подбор.ПометкаУдаления                          КАК ПометкаУдаления,
	|	Подбор.Услуга                                   КАК Услуга,
	|	Подбор.Номенклатура                             КАК Номенклатура,
	|	Подбор.Родитель                                 КАК Родитель,
	|	Подбор.ЕдиницаИзмерения                         КАК ЕдиницаИзмерения,
	|	Подбор.Номенклатура.Представление               КАК ПредставлениеНоменклатура,
	|	Подбор.ЕдиницаИзмерения.НаименованиеПолное      КАК ПредставлениеЕдиницаИзмерения,
	|	ВЫБОР
	|		КОГДА Подбор.ЭтоГруппа ТОГДА ""Группа""
	|		ИНАЧЕ Подбор.Номенклатура.НоменклатурнаяГруппа.Представление
	|	КОНЕЦ                                           КАК ПредставлениеНоменклатурнаяГруппа,
	|	Ложь                                            КАК ПереходитьВверх
	|ИЗ
	|
	|(
	|ВЫБРАТЬ
	|	СправочникНоменклатура.Код                               КАК Код,
	|	СправочникНоменклатура.ЭтоГруппа                         КАК ЭтоГруппа,
	|	СправочникНоменклатура.ПометкаУдаления                   КАК ПометкаУдаления,
	|	СправочникНоменклатура.Услуга                            КАК Услуга,
	|	СправочникНоменклатура.Ссылка                            КАК Номенклатура,
	|	СправочникНоменклатура.Родитель                          КАК Родитель,
	|	СправочникНоменклатура.БазоваяЕдиницаИзмерения           КАК ЕдиницаИзмерения
	|ИЗ
	|	Справочник.Номенклатура КАК СправочникНоменклатура
	|
	|ГДЕ
	|	СправочникНоменклатура.Родитель = &Родитель
	|	И
	|	(СправочникНоменклатура.Услуга = Истина
	|	ИЛИ
	|	СправочникНоменклатура.ЭтоГруппа = Истина)
	|
	|СГРУППИРОВАТЬ ПО
	|	СправочникНоменклатура.Родитель,
	|	СправочникНоменклатура.Ссылка
	|
	|) КАК Подбор
	|
	|УПОРЯДОЧИТЬ ПО
	|	Подбор.ЭтоГруппа УБЫВ,
	|	Подбор.Номенклатура.Наименование
	|";

	Возврат ТекстЗапроса;

КонецФункции // ЗапросРасходУслуги()

// Функция формирует текст запроса по ИмяПодбора = "РасходЦеныУслуг" для заполнения табличной части
//
// Возвращаемое значение:
//   Текст запроса
//
Функция ЗапросЦеныУслуг()

	ТекстЗапроса = "
	|ВЫБРАТЬ
	|	Подбор.Код                                      КАК Код,
	|	Подбор.ЭтоГруппа                                КАК ЭтоГруппа,
	|	Подбор.ПометкаУдаления                          КАК ПометкаУдаления,
	|	Подбор.Услуга                                   КАК Услуга,
	|	Подбор.Номенклатура                             КАК Номенклатура,
	|	Подбор.Родитель                                 КАК Родитель,
	|	Подбор.Цена                                     КАК Цена,
	|	Подбор.ЕдиницаИзмерения                         КАК ЕдиницаИзмерения,
	|	Подбор.Валюта                                   КАК Валюта,
	|	Подбор.Номенклатура.Представление               КАК ПредставлениеНоменклатура,
	|	Подбор.ЕдиницаИзмерения.НаименованиеПолное      КАК ПредставлениеЕдиницаИзмерения,
	|	Подбор.Валюта.Представление                     КАК ПредставлениеВалюта,
	|	ВЫБОР
	|		КОГДА Подбор.ЭтоГруппа ТОГДА ""Группа""
	|		ИНАЧЕ Подбор.Номенклатура.НоменклатурнаяГруппа.Представление
	|	КОНЕЦ                                           КАК ПредставлениеНоменклатурнаяГруппа,
	|	Ложь                                            КАК ПереходитьВверх
	|ИЗ
	|
	|(
	|ВЫБРАТЬ
	|	СправочникНоменклатура.Код                               КАК Код,
	|	СправочникНоменклатура.ЭтоГруппа                         КАК ЭтоГруппа,
	|	СправочникНоменклатура.ПометкаУдаления                   КАК ПометкаУдаления,
	|	СправочникНоменклатура.Услуга                            КАК Услуга,
	|	СправочникНоменклатура.Ссылка                            КАК Номенклатура,
	|	СправочникНоменклатура.Родитель                          КАК Родитель,
	|	МАКСИМУМ(ЦеныСрезПоследних.Цена) 						 КАК Цена,
	|	СправочникНоменклатура.БазоваяЕдиницаИзмерения 			 КАК ЕдиницаИзмерения,
	|	МАКСИМУМ(ЦеныСрезПоследних.Валюта) 						 КАК Валюта
	|ИЗ
	|	Справочник.Номенклатура КАК СправочникНоменклатура
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&ДатаРегистраСведений, " + мТекстЗапросаОтборНоменклатурыПоРодителю + " И ТипЦен = &ТипЦен) КАК ЦеныСрезПоследних
	|ПО
	|	ЦеныСрезПоследних.Номенклатура = СправочникНоменклатура.Ссылка
	|
	|ГДЕ
	|	(СправочникНоменклатура.Родитель = &Родитель) И
	|	(СправочникНоменклатура.Ссылка.ЭтоГруппа ИЛИ СправочникНоменклатура.Услуга = Истина)
	|
	|СГРУППИРОВАТЬ ПО
	|	СправочникНоменклатура.Родитель,
	|	СправочникНоменклатура.Ссылка
	|
	|) КАК Подбор
	|
	|УПОРЯДОЧИТЬ ПО
	|	Подбор.ЭтоГруппа УБЫВ,
	|	Подбор.Номенклатура.Наименование
	|";

	Возврат ТекстЗапроса;

КонецФункции // ЗапросРасходЦеныУслуг()

// Функция определяет какой запрос надо использовать для заполнения табличной части
//
// Параметры
//  ИмяПодбора  - строка, имя подбора для определения запроса
//  Родитель    - СправочникСсылка.Номенклатура, родитель для элементов, по коротым будет строиться запрос
//  ДатаЗапроса - Дата, на которую будут рассчитываться остатки и пр.
//
// Возвращаемое значение:
//   Запрос, с заполненным текстом и параметрами
//
Функция ПолучитьЗапросДляПодбора(ИмяПодбора, Родитель, ДатаЗапроса) Экспорт

	Запрос = Новый Запрос;
    Условие = "Организация = &Организация";
	ФильтрПоСубконто = "";
	ФильтрПоСчету = "";
	СписокПараметровЗапроса = ПолучитьСписокПараметровЗапроса(ИмяПодбора);
	ВидСубконто = Новый Массив;

	//Если ИмяПодбора = "ОстаткиИЦеныНоменклатуры"
	//	ИЛИ ИмяПодбора = "ОстаткиИПлановаяСебестоимость" Тогда

	//	Запрос.УстановитьПараметр("Дата"                 , ДатаЗапроса);
	//	Запрос.УстановитьПараметр("ДатаРегистраСведений" , ?(ЗначениеНеЗаполнено(ДатаЗапроса), ТекущаяДата(), ДатаЗапроса));
	//	Запрос.УстановитьПараметр("Родитель"             , Родитель);
	//	Для каждого ЭлементСписка Из СписокПараметровЗапроса Цикл
	//		Запрос.УстановитьПараметр(ЭлементСписка.Значение , СтруктураИсходныхПараметров[ЭлементСписка.Значение]);
	//	КонецЦикла;
	//	
	//	Если ИмяПодбора = "ОстаткиИПлановаяСебестоимость" Тогда
	//		ПлановыйТипЦен = Константы.ТипЦенПлановойСебестоимостиНоменклатуры.Получить();
	//		Запрос.УстановитьПараметр("ТипЦен", ПлановыйТипЦен);
	//	Иначе
	//		ТипЦен = Неопределено;
	//		СтруктураИсходныхПараметров.Свойство("ТипЦен", ТипЦен);
	//	КонецЕсли;

	//	Склад = Неопределено;
	//	СтруктураИсходныхПараметров.Свойство("Склад", Склад);
	//	ВедетсяУчетПоСкладам  = ?(Планысчетов.Хозрасчетный.ТоварыНаСкладах.ВидыСубконто.Найти(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Склады, "ВидСубконто") = Неопределено, Ложь, Истина);
	//	ЕстьСклад = ?(Склад = Неопределено, Ложь, Истина);
	//	
	//	ВидСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Номенклатура);
	//	ФильтрПоСубконто = СтрЗаменить(мТекстЗапросаОтборНоменклатурыПоРодителю, "Номенклатура В (", " И Субконто1 В (");
	//	Если ВедетсяУчетПоСкладам и ЕстьСклад Тогда
	//		ВидСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Склады);
	//		ФильтрПоСубконто = ФильтрПоСубконто + " И Субконто2 = &Склад";
	//	КонецЕсли;
	//	Запрос.УстановитьПараметр("ВидыСубконто", ВидСубконто);
	//	
	//	Запрос.Текст = ЗапросОстаткиИЦеныНоменклатуры(ФильтрПоСубконто, Условие, ФильтрПоСчету);
	//	
	//ИначеЕсли ИмяПодбора = "ЦеныНоменклатуры" Тогда
	Если ИмяПодбора = "ЦеныНоменклатуры" Тогда
		
		Запрос.УстановитьПараметр("Дата"                 , ДатаЗапроса);
		Запрос.УстановитьПараметр("ДатаРегистраСведений" , ?(ЗначениеНеЗаполнено(ДатаЗапроса), ТекущаяДата(), ДатаЗапроса));
		Запрос.УстановитьПараметр("Родитель"             , Родитель);
		Для каждого ЭлементСписка Из СписокПараметровЗапроса Цикл
			Запрос.УстановитьПараметр(ЭлементСписка.Значение , СтруктураИсходныхПараметров[ЭлементСписка.Значение]);
		КонецЦикла;

		Запрос.Текст = ЗапросЦеныНоменклатуры();
		
	ИначеЕсли ИмяПодбора = "ОстаткиНоменклатуры" Тогда

		Запрос.УстановитьПараметр("Дата"                 , ДатаЗапроса);
		Запрос.УстановитьПараметр("ДатаРегистраСведений" , ?(ЗначениеНеЗаполнено(ДатаЗапроса), ТекущаяДата(), ДатаЗапроса));
		Запрос.УстановитьПараметр("Родитель", Родитель);
		Для каждого ЭлементСписка Из СписокПараметровЗапроса Цикл
			Запрос.УстановитьПараметр(ЭлементСписка.Значение , СтруктураИсходныхПараметров[ЭлементСписка.Значение]);
		КонецЦикла;

		Склад = Неопределено;
		СтруктураИсходныхПараметров.Свойство("Склад", Склад);
		ВедетсяУчетПоСкладам  = ?(Планысчетов.Хозрасчетный.А1010.ВидыСубконто.Найти(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Склады, "ВидСубконто") = Неопределено, Ложь, Истина);
		ЕстьСклад = ?(Склад = Неопределено, Ложь, Истина);
		
		ВидСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Номенклатура);
		ФильтрПоСубконто = "";//СтрЗаменить(мТекстЗапросаОтборНоменклатурыПоРодителю, "Номенклатура В (", " И Субконто1 В (");
		Если ВедетсяУчетПоСкладам и ЕстьСклад Тогда
			ВидСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Склады);
			ФильтрПоСубконто = ФильтрПоСубконто + " И Субконто2 = &Склад";
		КонецЕсли;
		Запрос.УстановитьПараметр("ВидыСубконто", ВидСубконто);
		
		
		Если СтруктураИсходныхПараметров.Свойство("СчетУчета") Тогда
			Если СтруктураИсходныхПараметров.СчетУчета="014" Тогда
				ФильтрПоСчету="Счет = &ФильтрПоСчету";
				Запрос.УстановитьПараметр("ФильтрПоСчету", ПланыСчетов.Хозрасчетный.НайтиПоКоду("014"));
			КонецЕсли; 
		Иначе
			ФильтрПоСчету="Счет <> &ФильтрПоСчету";
			Запрос.УстановитьПараметр("ФильтрПоСчету", ПланыСчетов.Хозрасчетный.НайтиПоКоду("014"));
		КонецЕсли; 
		
		Запрос.Текст = ЗапросОстаткиНоменклатуры(ФильтрПоСубконто, Условие, ФильтрПоСчету);
    КонецЕсли;

	Если ПустаяСтрока(Запрос.Текст) Тогда
		Возврат Неопределено;
	Иначе
		Возврат Запрос;
	КонецЕсли; 

КонецФункции // ПолучитьЗапросДляПодбора()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ФОРМЫ ВВОДА ДОПОЛНИТЕЛЬНЫХ ПАРАМЕТРОВ

// Процедура формирует и выводит сумму в информационной надписи.
//
Процедура мОбновитьНадписьФомулаСумма(Форма) Экспорт

	Форма.ЭлементыФормы.НадписьФомулаСумма.Заголовок = ФорматСумм(Форма.Цена * Форма.Количество,,"0,00");
	
КонецПроцедуры // мОбновитьНадписьФомулаСумма()

// Процедура возвращает в форму-владельца выбранные значения.
//
Процедура мВыборВозврат(Форма) Экспорт

	СтруктураПараметров = Новый Структура();
	СтруктураПараметров.Вставить("ЕдиницаИзмерения", Форма.ЕдиницаИзмерения);
	СтруктураПараметров.Вставить("Количество",       Форма.Количество);
	СтруктураПараметров.Вставить("Цена",             Форма.Цена);

	Форма.Закрыть(СтруктураПараметров);

КонецПроцедуры // мВыборВозврат()

// Процедура - обработчик события "ПриОткрытии" формы.
//
Процедура мПриОткрытии(Форма) Экспорт

	Перем ЗапрашиватьЦену, ЗапрашиватьСерию;
	Перем ЕстьЦена, ЕстьКоличество;

	Форма.Заголовок = "Количество и цена """ + Форма.Номенклатура + """";

	ЗапрашиватьКоличество = Форма.ВладелецФормы.ЗапрашиватьКоличество;
	ЗапрашиватьЦену       = Форма.ВладелецФормы.ЗапрашиватьЦену;

	Форма.ЭлементыФормы.НадписьКоличество. Доступность = ЗапрашиватьКоличество;
	Форма.ЭлементыФормы.Количество.        Доступность = ЗапрашиватьКоличество;
	Форма.ЭлементыФормы.ЕдиницаИзмерения.  Доступность = ЗапрашиватьКоличество;
	Форма.ЭлементыФормы.НадписьЦена.       Доступность = ЗапрашиватьЦену;
	Форма.ЭлементыФормы.Цена.              Доступность = ЗапрашиватьЦену;
	Форма.ЭлементыФормы.НадписьВалютаЦены. Доступность = ЗапрашиватьЦену;
	Форма.ЭлементыФормы.НадписьВалютаСуммы.Доступность = ЗапрашиватьЦену;
	Форма.ЭлементыФормы.НадписьСумма.      Доступность = ЗапрашиватьЦену;

	мОбновитьНадписьФомулаСумма(Форма);

КонецПроцедуры // мПриОткрытии()

// Процедура - обработчик события "ПриЗакрытии" формы.
//
Процедура мПередЗакрытием(Форма) Экспорт

КонецПроцедуры // мПередЗакрытием()

// Процедура - обработчик события "ОбновлениеОтображения" формы.
//
Процедура мОбновлениеОтображения(Форма) Экспорт

КонецПроцедуры // мОбновлениеОтображения()

// Процедура - обработчик события "ОбработкаВыбора" поля ввода единицы измерения.
//  Пересчитывает цену при изменении единицы измерения.
//
Процедура мЕдиницаИзмеренияОбработкаВыбора(Форма, Элемент, ВыбранноеЗначение, СтандартнаяОбработка) Экспорт
	
	Форма.Активизировать();

КонецПроцедуры // мЕдиницаИзмеренияОбработкаВыбора()

// Процедура - обработчик события "ПриИзменении" поля ввода количества.
//
Процедура мКоличествоПриИзменении(Форма, Элемент) Экспорт

	мОбновитьНадписьФомулаСумма(Форма);

КонецПроцедуры // мКоличествоПриИзменении()

// Процедура - обработчик события "ПриИзменении" поля ввода цены.
//
Процедура мЦенаПриИзменении(Форма, Элемент) Экспорт

	мОбновитьНадписьФомулаСумма(Форма);

КонецПроцедуры // мЦенаПриИзменении()

// Процедура - обработчик события "Нажатие" кнопки "ОК".
//
Процедура мКнопкаОКНажатие(Форма, Элемент) Экспорт

	мВыборВозврат(Форма);

КонецПроцедуры // мКнопкаОКНажатие()

Процедура мЕдиницаИзмеренияПриИзменении(Форма, Элемент) Экспорт

	мОбновитьНадписьФомулаСумма(Форма);

КонецПроцедуры // мЕдиницаИзмеренияПриИзменении()

мТекстЗапросаОтборНоменклатурыПоРодителю = "
|Номенклатура В (ВЫБРАТЬ Номенклатура.Ссылка ИЗ Справочник.Номенклатура
|	        КАК Номенклатура ГДЕ Номенклатура.Родитель = &Родитель )";

#КонецЕсли