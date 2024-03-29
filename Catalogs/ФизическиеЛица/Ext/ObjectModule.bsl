﻿Перем мДлинаСуток;

Процедура ПроверитьДубли(ЗаписьПаспортныхДанных, ИНН, ИНПС, ФИО) Экспорт
	
	ЕстьДублиПаспортныхДанных 	= Ложь;
	ЕстьДублиИНН 				= Ложь;
	ЕстьДублиПФР 				= Ложь;
	
	Если НЕ ЗначениеНеЗаполнено(ЗаписьПаспортныхДанных.ДокументВид) ИЛИ
		 НЕ ЗначениеНеЗаполнено(ЗаписьПаспортныхДанных.ДокументСерия) ИЛИ
		 НЕ ЗначениеНеЗаполнено(ЗаписьПаспортныхДанных.ДокументНомер) ИЛИ
		 НЕ ЗначениеНеЗаполнено(ЗаписьПаспортныхДанных.ДокументДатаВыдачи) ИЛИ
		 НЕ ЗначениеНеЗаполнено(ЗаписьПаспортныхДанных.ДокументКодПодразделения) ТОГДА
		ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
		               |	ПаспортныеДанныеФизЛиц.ФизЛицо
		               |ИЗ
		               |	РегистрСведений.ПаспортныеДанныеФизЛиц КАК ПаспортныеДанныеФизЛиц
		               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ПаспортныеДанныеФизЛиц КАК ПаспортныеДанныеФизЛиц1
		               |		ПО (ПаспортныеДанныеФизЛиц.ДокументВид = &ДокументВид) И (ПаспортныеДанныеФизЛиц.ДокументСерия = &ДокументСерия) И (ПаспортныеДанныеФизЛиц.ДокументНомер = &ДокументНомер) И (ПаспортныеДанныеФизЛиц.ДокументДатаВыдачи = &ДокументДатаВыдачи) И (ПаспортныеДанныеФизЛиц.ДокументКодПодразделения = &ДокументКодПодразделения)
		               |
		               |ГДЕ
		               |	ПаспортныеДанныеФизЛиц.ФизЛицо <> &Ссылка";
		ЗапросПоДублям 	= Новый Запрос(ТекстЗапроса);
		ЗапросПоДублям.УстановитьПараметр("Ссылка", 					Ссылка);
		ЗапросПоДублям.УстановитьПараметр("ДокументВид", 				ЗаписьПаспортныхДанных.ДокументВид);
		ЗапросПоДублям.УстановитьПараметр("ДокументСерия",	 			ЗаписьПаспортныхДанных.ДокументСерия);
		ЗапросПоДублям.УстановитьПараметр("ДокументНомер", 				ЗаписьПаспортныхДанных.ДокументНомер);
		ЗапросПоДублям.УстановитьПараметр("ДокументДатаВыдачи", 		ЗаписьПаспортныхДанных.ДокументДатаВыдачи);
		ЗапросПоДублям.УстановитьПараметр("ДокументКодПодразделения",	ЗаписьПаспортныхДанных.ДокументКодПодразделения);
		РезультатЗапросаПоДублям 	= ЗапросПоДублям.Выполнить();
		ВыборкаЗапроса 				= РезультатЗапросаПоДублям.Выбрать();
		Пока ВыборкаЗапроса.Следующий() Цикл
			Сообщить("Физлицо: " + ВыборкаЗапроса.Физлицо +" имеет такие же паспортные данные как и у "+Строка(Ссылка));
			ЕстьДублиПаспортныхДанных = Истина;
		КонецЦикла;
	КонецЕсли;
	Если НЕ ЗначениеНеЗаполнено(ИНН) тогда
		ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
		               |	ФизическиеЛица.Ссылка КАК Физлицо
		               |ИЗ
		               |	Справочник.ФизическиеЛица КАК ФизическиеЛица
		               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ФизическиеЛица КАК ФизическиеЛица1
		               |		ПО (ФизическиеЛица.ИНН = &ИНН)
		               |ГДЕ
		               |	ФизическиеЛица.Ссылка <> &Ссылка";
		ЗапросПоДублям 	= Новый Запрос(ТекстЗапроса);
		ЗапросПоДублям.УстановитьПараметр("Ссылка", 				Ссылка);
		ЗапросПоДублям.УстановитьПараметр("ИНН", 					ИНН);
		РезультатЗапросаПоДублям 	= ЗапросПоДублям.Выполнить();
		ВыборкаЗапроса 				= РезультатЗапросаПоДублям.Выбрать();
		Пока ВыборкаЗапроса.Следующий() Цикл
			Сообщить("Физлицо: " + ВыборкаЗапроса.Физлицо +" имеет такой же ИНН как и у "+Строка(Ссылка));
			ЕстьДублиИНН = Истина;
		КонецЦикла;
	КонецЕсли;
	Если НЕ ЗначениеНеЗаполнено(ИНПС) тогда
		ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
		               |	ФизическиеЛица.Ссылка КАК Физлицо
		               |ИЗ
		               |	Справочник.ФизическиеЛица КАК ФизическиеЛица
		               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ФизическиеЛица КАК ФизическиеЛица1
		               |		ПО (ФизическиеЛица.ИНПС = &ИНПС)
		               |ГДЕ
		               |	ФизическиеЛица.Ссылка <> &Ссылка";
		ЗапросПоДублям 	= Новый Запрос(ТекстЗапроса);
		ЗапросПоДублям.УстановитьПараметр("Ссылка", 				Ссылка);
		ЗапросПоДублям.УстановитьПараметр("ИНПС", 					ИНПС);
		РезультатЗапросаПоДублям 	= ЗапросПоДублям.Выполнить();
		ВыборкаЗапроса 				= РезультатЗапросаПоДублям.Выбрать();
		Пока ВыборкаЗапроса.Следующий() Цикл
			Сообщить("Физлицо: " + ВыборкаЗапроса.Физлицо +" имеет такой же номер ИНПС как и у "+Строка(Ссылка));
			ЕстьДублиПФР = Истина;
		КонецЦикла;
	КонецЕсли;
	Если НЕ ЗначениеНеЗаполнено(ФИО) И
		 НЕ ЕстьДублиИНН И
		 НЕ ЕстьДублиПаспортныхДанных И
		 НЕ ЕстьДублиПФР тогда
		ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
		               |	ФИОФизЛиц.ФизЛицо
		               |ИЗ
		               |	РегистрСведений.ФИОФизЛиц КАК ФИОФизЛиц
		               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ФИОФизЛиц КАК ФИОФизЛиц1
		               |		ПО (ФИОФизЛиц.Фамилия+ФИОФизЛиц.Имя+ФИОФизЛиц.Отчество = &ФИО)
		               |
		               |ГДЕ
		               |	ФИОФизЛиц.ФизЛицо <> &Ссылка";
		ЗапросПоДублям 	= Новый Запрос(ТекстЗапроса);
		ЗапросПоДублям.УстановитьПараметр("Ссылка",	Ссылка);
		ЗапросПоДублям.УстановитьПараметр("ФИО", 	СтрЗаменить(ФИО, " ", ""));
		РезультатЗапросаПоДублям 	= ЗапросПоДублям.Выполнить();
		ВыборкаЗапроса 				= РезультатЗапросаПоДублям.Выбрать();
		Пока ВыборкаЗапроса.Следующий() Цикл
			Сообщить("Физлицо с таким ФИО (" + ВыборкаЗапроса.Физлицо +") уже есть в справочнике");
			ЕстьДублиПаспортныхДанных = Истина;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

#Если Клиент Тогда

// Процедура выводит на экран печатную форму 
	//
	// Параметры: 
	//  Нет
	//
	// Возвращаемое значение:
	//  Нет.
	//
Процедура Печать() Экспорт

	СтруктураДанных = Новый Структура; 
	СтруктураДанныхОрганизации = Новый Структура; 

	Запрос = Новый Запрос;

	// Установим параметры запроса.
	Запрос.УстановитьПараметр("ФизЛицо" ,	Ссылка);
	Запрос.УстановитьПараметр("ДатаАктуальности" ,	РабочаяДата);
	Запрос.УстановитьПараметр("ПустаяСтрока" ,"");
	Запрос.УстановитьПараметр("ПустаяДата", Дата('00010101'));
	Запрос.УстановитьПараметр("Проведен" ,Истина);

	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ФизическиеЛица.Наименование,
	|	ФизическиеЛица.ДатаРождения,
	|	ФизическиеЛица.ИНН,
	|	ФизическиеЛица.Код,
	|	ФизическиеЛица.Пол,
	|	ФизическиеЛица.ИНПС,
	|	ПаспортныеДанныеФизЛицСрезПоследних.ДокументВид.Представление КАК ДокументВид,
	|	ПаспортныеДанныеФизЛицСрезПоследних.ДокументДатаВыдачи,
	|	ПаспортныеДанныеФизЛицСрезПоследних.ДокументКемВыдан,
	|	ПаспортныеДанныеФизЛицСрезПоследних.ДокументКодПодразделения,
	|	ПаспортныеДанныеФизЛицСрезПоследних.ДокументНомер,
	|	ПаспортныеДанныеФизЛицСрезПоследних.ДокументСерия,
	|	РаботникиСрезПоследних.ТабельныйНомер,
	|	РаботникиСрезПоследних.Должность.Представление КАК Должность,
	|	ФИОФизЛицСрезПоследних.Фамилия,
	|	ФИОФизЛицСрезПоследних.Имя,
	|	ФИОФизЛицСрезПоследних.Отчество
	|ИЗ
	|	Справочник.ФизическиеЛица КАК ФизическиеЛица
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ФИОФизЛиц.СрезПоследних(, ФизЛицо = &ФизЛицо) КАК ФИОФизЛицСрезПоследних
	|		ПО ФИОФизЛицСрезПоследних.ФизЛицо = ФизическиеЛица.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПаспортныеДанныеФизЛиц.СрезПоследних(, ФизЛицо = &ФизЛицо) КАК ПаспортныеДанныеФизЛицСрезПоследних
	|		ПО ФизическиеЛица.Ссылка = ПаспортныеДанныеФизЛицСрезПоследних.ФизЛицо
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций.СрезПоследних(, Сотрудник.ФизическоеЛицо = &ФизЛицо) КАК РаботникиСрезПоследних
	|		ПО ФизическиеЛица.Ссылка = РаботникиСрезПоследних.Сотрудник.ФизическоеЛицо
	|
	|ГДЕ
	|	ФизическиеЛица.Ссылка = &ФизЛицо";

	Результат = Запрос.Выполнить(); 
	ВыборкаДляПроверок = Результат.Выбрать();
	ВыборкаДляПроверок.Следующий();
	СтруктураДанных.Вставить("ФизическиеЛица", Результат.Выбрать());
	Если ВыборкаДляПроверок.ДокументВид <> Null Тогда
		СтруктураДанных.Вставить("ПаспортныеДанныеФизЛиц", Результат.Выбрать());
	КонецЕсли;

	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	КонтактнаяИнформация.Тип КАК Тип,
	|	ВЫБОР КОГДА КонтактнаяИнформация.Вид ССЫЛКА Справочник.ВидыКонтактнойИнформации ТОГДА
	|		КонтактнаяИнформация.Вид.Представление
	|	ИНАЧЕ
	|		КонтактнаяИнформация.Вид
	|	КОНЕЦ КАК ВидКИ,
	|	КонтактнаяИнформация.Представление КАК ПредставлениеКИ
	|ИЗ
	|	РегистрСведений.КонтактнаяИнформация КАК КонтактнаяИнформация
	|ГДЕ
	|	КонтактнаяИнформация.Объект = &ФизЛицо
	|УПОРЯДОЧИТЬ ПО
	|	Тип
	|АВТОУПОРЯДОЧИВАНИЕ";

	СтруктураДанных.Вставить("КонтактнаяИнформация", Запрос.Выполнить().Выбрать());

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ФизическиеЛица_ДанныеПоФизлицу";
	Макет = ПолучитьМакет("ДанныеПоФизлицу");

	Для Каждого СекцияДанных Из СтруктураДанных Цикл

		ИмяСекции = СекцияДанных.Ключ;
		УсловиеВыводаРаскрытойГруппы = ИмяСекции = "ФизическиеЛица";
		Выборка = СекцияДанных.Значение;
		Если ИмяСекции = "КонтактнаяИнформация" и НЕ Выборка.Количество() = 0 Тогда

			СекцияЗаголовка = Макет.ПолучитьОбласть("КонтактнаяИнформация_Заголовок");
			ТабДокумент.Вывести(СекцияЗаголовка);
			ТабДокумент.Область(ТабДокумент.ВысотаТаблицы,,ТабДокумент.ВысотаТаблицы,).ЦветФона = ЦветаСтиля.ФонГруппировкиВерхнегоУровня;
			ТабДокумент.НачатьГруппуСтрок("",Ложь);
			Отбивка = Макет.ПолучитьОбласть("Отбивка");
			
			СекцияТипаКИ = Макет.ПолучитьОбласть("КонтактнаяИнформация_Тип");
			Пока Выборка.СледующийПоЗначениюПоля("Тип") цикл

				ТабДокумент.Вывести(Отбивка);
				СекцияТипаКИ.Параметры.ТипКИ = Строка(Выборка.Тип) + ":";
				ТабДокумент.Вывести(СекцияТипаКИ);

				СекцияКИ = Макет.ПолучитьОбласть("КонтактнаяИнформация_Данные");
				Пока Выборка.СледующийПоЗначениюПоля("ВидКИ") цикл
					СекцияКИ.Параметры.Заполнить(Выборка);
					ТабДокумент.Вывести(СекцияКИ);
				КонецЦикла;

			КонецЦикла; 

			ТабДокумент.Вывести(Отбивка);
			ТабДокумент.ЗакончитьГруппуСтрок();
			
		ИначеЕсли Макет.Области.Найти(ИмяСекции + "_Заголовок") <> Неопределено и Выборка.Следующий() Тогда

			Отбивка = ?(Макет.Области.Найти(ИмяСекции + "_Отбивка") <> Неопределено,Макет.ПолучитьОбласть(ИмяСекции + "_Отбивка"),Макет.ПолучитьОбласть("Отбивка"));
			ОбластьМакета = Макет.ПолучитьОбласть(ИмяСекции + "_Заголовок");
			Если ОбластьМакета.Области.Количество() = 1 Тогда
				ТабДокумент.Вывести(ОбластьМакета);
				ТабДокумент.Область(ТабДокумент.ВысотаТаблицы,,ТабДокумент.ВысотаТаблицы,).ЦветФона = ЦветаСтиля.ФонГруппировкиВерхнегоУровня;
				ТабДокумент.НачатьГруппуСтрок("", УсловиеВыводаРаскрытойГруппы);
				ТабДокумент.Вывести(Отбивка);
			Иначе
				ОбластьМакета = Макет.ПолучитьОбласть(ИмяСекции + "_Заголовок_ПерваяСтрока");
				ТабДокумент.Вывести(ОбластьМакета);
				ТабДокумент.Область(ТабДокумент.ВысотаТаблицы,,ТабДокумент.ВысотаТаблицы,).ЦветФона = ЦветаСтиля.ФонГруппировкиВерхнегоУровня;
				ТабДокумент.НачатьГруппуСтрок("", УсловиеВыводаРаскрытойГруппы);
				ТабДокумент.Вывести(Отбивка);
				ОбластьМакета = Макет.ПолучитьОбласть(ИмяСекции + "_Заголовок_Остальное");
				Если ОбластьМакета.Параметры.Количество() = 0 Тогда // раскрашиваем заголовок без выведенных данных
					ТабДокумент.Область(ТабДокумент.ВысотаТаблицы, 2, ТабДокумент.ВысотаТаблицы, 10).ЦветФона = ЦветаСтиля.ФонГруппировкиПромежуточногоУровня;
				Иначе	
					ОбластьМакета.Параметры.Заполнить(Выборка);
				КонецЕсли;
				ТабДокумент.Вывести(ОбластьМакета);
				Если ОбластьМакета.Параметры.Количество() = 0 Тогда // раскрашиваем заголовок без выведенных данных
					ТабДокумент.Область(ТабДокумент.ВысотаТаблицы - ОбластьМакета.ВысотаТаблицы + 1, 2, ТабДокумент.ВысотаТаблицы, 10).ЦветФона = ЦветаСтиля.ФонГруппировкиПромежуточногоУровня;
				КонецЕсли;
			КонецЕсли;
			ОбластьМакета = Макет.ПолучитьОбласть(ИмяСекции + "_Данные");
			ОбластьМакета.Параметры.Заполнить(Выборка);
			Если ИмяСекции = "ФизическиеЛица" и ЗначениеНеЗаполнено(Выборка.Фамилия) Тогда
				Фамилия = " "; Имя = " "; Отчество = " ";
				ФамилияИнициалыФизЛица(ЭтотОбъект, Фамилия, Имя, Отчество);
				ОбластьМакета.Параметры.Фамилия = Фамилия;
				ОбластьМакета.Параметры.Имя = Имя;
				ОбластьМакета.Параметры.Отчество = Отчество;
			КонецЕсли;
			ТабДокумент.Вывести(ОбластьМакета);
			Пока Выборка.Следующий() Цикл
				ОбластьМакета.Параметры.Заполнить(Выборка);
				ТабДокумент.Вывести(ОбластьМакета);
			КонецЦикла;
			ТабДокумент.Вывести(Отбивка);
			ТабДокумент.ЗакончитьГруппуСтрок();

		КонецЕсли;	
	КонецЦикла;

	НапечататьДокумент(ТабДокумент,,, "Данные по: " + Наименование);

КонецПроцедуры // Печать

#КонецЕсли

Процедура ПриУстановкеНовогоКода(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ

мДлинаСуток = 86400;

