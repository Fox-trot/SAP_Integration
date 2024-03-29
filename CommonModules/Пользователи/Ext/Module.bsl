﻿// Функция возвращает список с наборами прав, доступными текущему пользователю
//
// Параметры:
//  нет.
//
// Возвращаемое значение:
//  Список значений с доступными ролями пользователя
//
Функция ПолучитьСписокНабораПрав() Экспорт

	НаборДоступныхРолейПользователя = Новый СписокЗначений;
	
	ЗначенияПеречисления = Метаданные.Перечисления.НаборПравПользователей.ЗначенияПеречисления;
	
	КоличествоНаборовПрав = Перечисления.НаборПравПользователей.Количество();
	Для а = 0 По КоличествоНаборовПрав - 1 Цикл
		Попытка
		Если РольДоступна(Строка(ЗначенияПеречисления[а].Имя)) Тогда
			НаборДоступныхРолейПользователя.Добавить(Перечисления.НаборПравПользователей[а]);
		//ИначеЕсли РольДоступна(Строка(ЗначенияПеречисления[а].Имя)+"СОграничениемПравДоступа") Тогда
		//	НаборДоступныхРолейПользователя.Добавить(Перечисления.НаборПравПользователей[а]);
		КонецЕсли;
		Исключение КонецПопытки;
	КонецЦикла;

	Возврат НаборДоступныхРолейПользователя;

КонецФункции // ПолучитьСписокНабораПрав()

// Возвращает договор контрагента, если организация, указанная
// в данном договоре доступна пользователю
Функция ДоступныйДоговорКонтрагента(ДоговорСсылка) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДоговорСсылка", ДоговорСсылка);
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ДоговорыКонтрагентов.Ссылка КАК Договор,
	|	ДоговорыКонтрагентов.Организация
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.Ссылка = &ДоговорСсылка";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		ДоговорКонтрагента = Выборка.Договор;
		
	Иначе
		ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
	КонецЕсли;
	
	Возврат ДоговорКонтрагента;
	
КонецФункции // ДоступныйДоговорКонтрагента()

// Функция возвращает список значений права, установленных для пользователя.
// Если количество значений меньше количество доступных ролей, то возвращается значение по умолчанию
//
// Параметры:
//  Право               - право, для которого определяются значения
//  ЗначениеПоУмолчанию - значение по умолчанию для передаваемого права (возвращается в случае
//                        отсутствия значений в регистре сведений)
//
// Возвращаемое значение:
//  Список всех значений, установленных наборам прав (ролям), доступных пользователю
//
Функция ПолучитьЗначениеПраваДляТекущегоПользователя(Право, ЗначениеПоУмолчанию = Неопределено) Экспорт

	ВозвращаемыеЗначения = Новый СписокЗначений;
	СписокНабораПрав = ПолучитьСписокНабораПрав();

	Запрос = Новый Запрос;

	Запрос.УстановитьПараметр("НаборПрав"        , СписокНабораПрав);
	Запрос.УстановитьПараметр("ПравоПользователя", Право);

	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Значение
	|ИЗ
	|	РегистрСведений.ЗначенияПравПользователя КАК РегистрЗначениеПрав
	|
	|ГДЕ
	|	Право = &ПравоПользователя
	| И НаборПрав В(&НаборПрав)
	|
	|";

	Выборка = Запрос.Выполнить().Выбрать();

	Если Выборка.Количество() < СписокНабораПрав.Количество() Тогда
		ВозвращаемыеЗначения.Добавить(ЗначениеПоУмолчанию);
	КонецЕсли;

	Пока Выборка.Следующий() Цикл
		Если ВозвращаемыеЗначения.НайтиПоЗначению(Выборка.Значение) = Неопределено Тогда
			ВозвращаемыеЗначения.Добавить(Выборка.Значение);
		КонецЕсли;
	КонецЦикла;

	Возврат ВозвращаемыеЗначения;

КонецФункции // ПолучитьЗначениеПраваДляТекущегоПользователя()

// Процедура проверяет возможность запуска ИБ с определенными для текущего
// пользователя доступными ролями
//
Процедура ПроверитьВозможностьРаботыПользователя(Отказ) Экспорт

	Если НЕ ЕстьДоступныеПраваДляЗапускаКонфигурации() Тогда
		Отказ = Истина;
		#Если Клиент Тогда
		Предупреждение("У текущего пользователя нет доступных ролей, для запуска информационной базы.", 10, "Недостаточно прав доступа");
		#КонецЕсли
	КонецЕсли; 
	
КонецПроцедуры

// Функция возвращает значение по умолчанию для передаваемого пользователя и настройки.
//
// Параметры:
//  Пользователь - текущий пользователь программы
//  Настройка    - признак, для которого возвращается значение по умолчанию
//
// Возвращаемое значение:
//  Значение по умолчанию для настройки.
//
Функция ПолучитьЗначениеПоУмолчанию(Пользователь, Настройка) Экспорт

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Пользователь", Пользователь);
	Запрос.УстановитьПараметр("Настройка"   , ПланыВидовХарактеристик.НастройкиПользователей[Настройка]);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	Значение
	|ИЗ
	|	РегистрСведений.НастройкиПользователей КАК РегистрЗначениеПрав
	|
	|ГДЕ
	|	Пользователь = &Пользователь
	| И Настройка    = &Настройка";

	Выборка = Запрос.Выполнить().Выбрать();

	ПустоеЗначение = ПланыВидовХарактеристик.НастройкиПользователей[Настройка].ТипЗначения.ПривестиЗначение();

	Если Выборка.Количество() = 0 Тогда
		
		Если (Настройка = "ОткрыватьПриЗапускеПанельФункций") ИЛИ (Настройка = "ПоказыватьОписанияПанелиФункций") Тогда
			Возврат Истина;
		КонецЕсли;
		
		Возврат ПустоеЗначение;

	ИначеЕсли Выборка.Следующий() Тогда

		Если ЗначениеНеЗаполнено(Выборка.Значение) Тогда
			Возврат ПустоеЗначение;
		Иначе
			Возврат Выборка.Значение;
		КонецЕсли;

	Иначе
		Возврат ПустоеЗначение;

	КонецЕсли;

КонецФункции // ПолучитьЗначениеПоУмолчанию()

// Процедура записывает значение по умолчанию для передаваемого пользователя и настройки.
//
// Параметры:
//  Пользователь - текущий пользователь программы
//  Настройка    - признак, для которого записывается значение по умолчанию
//  Значение     - значение по умолчанию
//
// Возвращаемое значение:
//  Нет
//
Процедура УстановитьЗначениеПоУмолчанию(Пользователь, Настройка, Значение) Экспорт
	//Если Пользователь <> Неопределено Тогда
		СсылкаНастройки = ПланыВидовХарактеристик.НастройкиПользователей[Настройка];
		МенеджерЗаписи = РегистрыСведений.НастройкиПользователей.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Пользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
		МенеджерЗаписи.Пользователь = Пользователь;
		МенеджерЗаписи.Настройка = СсылкаНастройки;
		МенеджерЗаписи.Значение = Значение;
		МенеджерЗаписи.Записать(Истина);
	
	//КонецЕсли;
КонецПроцедуры // ПолучитьЗначениеПоУмолчанию()

//Функция создает нового пользователя БД с настройками по умолчанию и возвращает его
Функция ДобавитьНовогоПользователяБД(ИмяПользователя, ПолноеИмя = Неопределено, СообщатьОДобавленииПользователя = Истина, ЗаписатьПользователяВБД = Истина) Экспорт
	
	НовыйПользователь = ПользователиИнформационнойБазы.СоздатьПользователя();
	НовыйПользователь.Имя = ИмяПользователя;
	НовыйПользователь.ПолноеИмя = ?(ЗначениеНеЗаполнено(ПолноеИмя), ИмяПользователя, ПолноеИмя);
	
	НовыйПользователь.АутентификацияСтандартная = Истина;
	НовыйПользователь.ПоказыватьВСпискеВыбора = Истина;
	
	Если ЗаписатьПользователяВБД Тогда
		НовыйПользователь.Роли.Добавить(Метаданные.Роли.ПравоЗапуска);
		Попытка
			НовыйПользователь.Записать();
			#Если Клиент Тогда
			Если СообщатьОДобавленииПользователя Тогда
				Сообщить("В список пользователей БД добавлен пользователь с именем """ + ИмяПользователя + """");
			КонецЕсли;
			#КонецЕсли

		Исключение
		
			#Если Клиент Тогда
			Сообщить("Ошибка при добавлении пользователя в список пользователей БД """ + ИмяПользователя + """");
			#КонецЕсли
	
		КонецПопытки;
	
	КонецЕсли;	
	
	Возврат НовыйПользователь;
КонецФункции

// Функция по имени ищет пользователя БД, если не находит - создает нового и его возвращает
// Параметры:
//	ИмяПользователя - строка по которой ищется пользователь БД
//  ПолноеИмяПользователя - строка, при добавлении пользователя БД таким будет установлено полное имя пользователя
//	СообщатьОДобавленииПользователя - Булево, нужно ли сообщать о добавлении нового пользователя БД
//	ЗаписатьПользователяВБД - Нужно ли при добавлении пользователя записывать его
Функция НайтиИлиСоздатьПользователяБД(ИмяПользователя, ПолноеИмяПользователя = Неопределено, СообщатьОДобавленииПользователя = Истина, ЗаписатьПользователяВБД = Истина) Экспорт
	
	Если ИмяПользователя = "НеАвторизован" Тогда
		ПользовательИБ = Неопределено
	Иначе
		// ищем пользователя БД по имени
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ИмяПользователя);
		Если ПользовательИБ = Неопределено Тогда
			ПользовательИБ = ДобавитьНовогоПользователяБД(ИмяПользователя, ПолноеИмяПользователя, СообщатьОДобавленииПользователя, ЗаписатьПользователяВБД);
		КонецЕсли;
	
	КонецЕсли;
	
	Возврат ПользовательИБ;
КонецФункции

// Функция дополняет ИМЯ пробелами справа до длины 50
Функция СформироватьИмяПользователяВСправочнике(Имя) Экспорт
	
	ИмяПользователя = Имя;
	Для Счетчик = СтрДлина(ИмяПользователя) + 1 По 50 Цикл
		ИмяПользователя = ИмяПользователя + " ";	
	КонецЦикла;
	
	ИмяПользователя = Лев(ИмяПользователя, 50);
	
	Возврат ИмяПользователя;
	
КонецФункции

// Процедура синхронизирует справочник пользователей с пользователями БД
Процедура СинхронизироватьПользователейИПользователейБД() Экспорт
	
	// 1 Пробегаем по справочнику пользователей и каких пользователей в БД
	// не нашли - тех добавляем
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ
	                |	Пользователи.*
	                |ИЗ
	                |	Справочник.Пользователи КАК Пользователи
					|
					| ГДЕ Пользователи.ЭтоГруппа = Ложь";
	
	ТаблицаПользователей = Запрос.Выполнить().Выгрузить();
	Для Каждого ПользовательСправочника Из ТаблицаПользователей Цикл
		
		Если Не ПользовательСправочника.ПометкаУдаления Тогда
			// Для пользователя с пустым именем не надо пользователя в БД создавать
			ИмяПользователяБД = СокрЛП(ПользовательСправочника.Код);
			Если ИмяПользователяБД <> "" Тогда           
				Если Не ПользовательСправочника.ПользовательПБД Тогда
					НайтиИлиСоздатьПользователяБД(ИмяПользователяБД, ПользовательСправочника.Наименование);
				КонецЕсли; 
			КонецЕсли;	
		КонецЕсли;
		    
	КонецЦикла;
	
	// 2 Пробегаем по пользователеям БД и тех кого не нашли в справочнике добавляем
    МассивПользователейБД = ПользователиИнформационнойБазы.ПолучитьПользователей();
	Для Каждого ПользовательБД Из МассивПользователейБД Цикл
		
		ИмяПользователяВСправочнике = СформироватьИмяПользователяВСправочнике(ПользовательБД.Имя);
		ПользовательСправочника = ТаблицаПользователей.Найти(ИмяПользователяВСправочнике, "Код");
		Если ПользовательСправочника = Неопределено Тогда
			
			Попытка
				ОбъектПользователь = Справочники.Пользователи.СоздатьЭлемент();
	            ОбъектПользователь.Код          = ИмяПользователяВСправочнике;
				ОбъектПользователь.Наименование = ПользовательБД.ПолноеИмя;
	            ОбъектПользователь.Записать();
				
				#Если Клиент Тогда
				Сообщить("Пользователь """ + ПользовательБД.Имя + """ зарегистрирован в справочнике пользователей.");
				#КонецЕсли
			Исключение
				СообщитьОбОшибке("Ошибка при добавлении пользователя """ + ПользовательБД.Имя + """ в справочник.");
		    КонецПопытки;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры


Функция АвторизованныйПользователь() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Возврат ПараметрыСеанса.ТекущийПользователь;
	
КонецФункции

Функция ТекущийПользователь() Экспорт
	
	АвторизованныйПользователь = АвторизованныйПользователь();
	
	Возврат АвторизованныйПользователь;
	
КонецФункции

// Проверяет, является ли текущий или указанный пользователь полноправным.
// 
// Полноправным считается пользователь, который
// а) при не пустом списке пользователей информационной базы:
// - в локальном режиме работы (без разделения данных) имеет роль ПолныеПрава и
//   роль для администрирования системы,
// - в модели сервиса (с разделением данных) имеет роль ПолныеПрава;
// б) при пустом списке пользователей информационной базы
//    основная роль конфигурации не задана или ПолныеПрава.
//
// Параметры:
//  Пользователь - Неопределено - проверяется текущий пользователь ИБ;
//                 СправочникСсылка.Пользователи,
//                 СправочникСсылка.ВнешниеПользователи - осуществляется поиск
//                    пользователя ИБ по уникальному идентификатору,
//                    заданному в реквизите ИдентификаторПользователяИБ.
//                    Прим.: если пользователь ИБ не найден, возвращается Ложь.
//                 ПользовательИнформационнойБазы - проверяется указанный
//                    пользователь ИБ.
//
//  ПроверятьПраваАдминистрированияСистемы - Булево - если задано Истина, тогда
//                 проверяется наличие роли для администрирования системы.
//                 Начальное значение: Ложь.
//
//  УчитыватьПривилегированныйРежим - Булево - если задано Истина, тогда
//                 функция возвращает Истина, когда установлен привилегированный режим.
//                 Начальное значение: Истина.
//
// Возвращаемое значение:
//  Булево.
//
Функция ЭтоПолноправныйПользователь(Пользователь = Неопределено,
                                    ПроверятьПраваАдминистрированияСистемы = Ложь,
                                    УчитыватьПривилегированныйРежим = Истина) Экспорт
	
	Если УчитыватьПривилегированныйРежим И ПривилегированныйРежим() Тогда
		Возврат Истина;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если ТипЗнч(Пользователь) = Тип("ПользовательИнформационнойБазы") Тогда
		ПользовательИБ = Пользователь;
		
	ИначеЕсли Пользователь = Неопределено ИЛИ Пользователь = АвторизованныйПользователь() Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.ТекущийПользователь();
		
	Иначе
		// Задан не текущий пользователь.
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
			ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Пользователь, "ИдентификаторПользователяИБ"));
		
		Если ПользовательИБ = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Если ПользовательИБ.УникальныйИдентификатор <> ПользователиИнформационнойБазы.ТекущийПользователь().УникальныйИдентификатор Тогда
		
		// Для не текущего пользователя ИБ проверяются роли в записанном пользователе ИБ.
		Если ПроверятьПраваАдминистрированияСистемы Тогда
			Возврат ПользовательИБ.Роли.Содержит(РольАдминистратораСистемы())
		Иначе
			Возврат ПользовательИБ.Роли.Содержит(Метаданные.Роли.ПолныеПрава)
		КонецЕсли;
	Иначе
		Если ЗначениеЗаполнено(ПользовательИБ.Имя) Тогда
			
			// Для текущего пользователя ИБ проверяются роли не в записанном пользователе ИБ,
			// а роли в текущем сеансе.
			Если ПроверятьПраваАдминистрированияСистемы Тогда
				Возврат РольДоступна(РольАдминистратораСистемы())
			Иначе
				Возврат РольДоступна(Метаданные.Роли.ПолныеПрава)
			КонецЕсли;
		Иначе
			// Для неуказанного пользователя ИБ проверяется основная роль конфигурации:
			// должна быть роль ПолныеПрава или не указана (привилегированный режим).
			Если Метаданные.ОсновнаяРоль = Неопределено ИЛИ
				 Метаданные.ОсновнаяРоль = Метаданные.Роли.ПолныеПрава Тогда
				Возврат Истина;
			Иначе
				Возврат Ложь;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

// Возвращает доступность хотя бы одной из указанных ролей или полноправность
// пользователя (текущего или указанного) без учета привилегированного режима.
//
// Параметры:
//  ИменаРолей   - Строка - имена ролей, разделенные запятыми, доступность которых проверяется.
//
//  Пользователь - Неопределено - проверяется текущий пользователь ИБ;
//                 СправочникСсылка.Пользователи,
//                 СправочникСсылка.ВнешниеПользователи - осуществляется поиск
//                    пользователя ИБ по уникальному идентификатору,
//                    заданному в реквизите ИдентификаторПользователяИБ
//                    Прим.: если пользователь ИБ не найден, возвращается Ложь.
//                 ПользовательИнформационнойБазы - проверяется указанный
//                    пользователь ИБ
//
// Возвращаемое значение:
//  Булево - Истина, если хотя бы одна из указанных ролей доступна,
//           или функция ЭтоПолноправныйПользователь(Пользователь) возвращает Истина.
//
Функция РолиДоступны(Знач ИменаРолей, Пользователь = Неопределено) Экспорт
	
	Если ЭтоПолноправныйПользователь(Пользователь, , Ложь) Тогда
		Возврат Истина;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Пользователь = Неопределено ИЛИ Пользователь = АвторизованныйПользователь() Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.ТекущийПользователь();
		
	ИначеЕсли ТипЗнч(Пользователь) = Тип("ПользовательИнформационнойБазы") Тогда
		ПользовательИБ = Пользователь;
		
	Иначе
		// Указан не текущий пользователь.
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
			ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Пользователь, "ИдентификаторПользователяИБ"));
		
		Если ПользовательИБ = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	УказанТекущийПользовательИБ = ПользовательИБ.УникальныйИдентификатор = ПользователиИнформационнойБазы.ТекущийПользователь().УникальныйИдентификатор;
	
	МассивИменРолей = СтрРазделить(ИменаРолей, ",");
	Для каждого ИмяРоли Из МассивИменРолей Цикл
		
		Если УказанТекущийПользовательИБ Тогда
			Если РольДоступна(СокрЛП(ИмяРоли)) Тогда
				Возврат Истина;
			КонецЕсли;
		Иначе
			Если ПользовательИБ.Роли.Содержит(Метаданные.Роли.Найти(СокрЛП(ИмяРоли))) Тогда
				Возврат Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции для работы с пользователями информационной базы

// Возвращает роль, предоставляющую права администрирования системы.
//
// Возвращаемое значение:
//  ОбъектМетаданных: Роль.
//
Функция РольАдминистратораСистемы() Экспорт
	
	РольАдминистратораСистемы = Метаданные.Роли.ПолныеПрава;
		
	Возврат РольАдминистратораСистемы;
	
КонецФункции
