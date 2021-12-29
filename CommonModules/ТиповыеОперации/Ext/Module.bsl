﻿
Функция тоОстатокНаСчете(Организация, ИмяРегистра, СчетУчета, Субконто1, Субконто2, Субконто3, Дата, Валюта) Экспорт

	Субконто = Новый Массив(3);

	Для Индекс = 0 по (Мин(СчетУчета.ВидыСубконто.Количество(),3) - 1) Цикл

		ТипСубконто = СчетУчета.ВидыСубконто[Индекс].ВидСубконто.ТипЗначения;

		Если ТипСубконто.СодержитТип(ТипЗнч(Субконто1)) Тогда
			Субконто[Индекс] = Субконто1;

		ИначеЕсли ТипСубконто.СодержитТип(ТипЗнч(Субконто2)) Тогда
			Субконто[Индекс] = Субконто2;

		ИначеЕсли ТипСубконто.СодержитТип(ТипЗнч(Субконто3)) Тогда
			Субконто[Индекс] = Субконто3;

		КонецЕсли;

	КонецЦикла;

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Субконто1",   Субконто[0]);
	Запрос.УстановитьПараметр("Субконто2",   Субконто[1]);
	Запрос.УстановитьПараметр("Субконто3",   Субконто[2]);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("СчетУчета",   СчетУчета);
	Запрос.УстановитьПараметр("Валюта",      Валюта);
	Запрос.УстановитьПараметр("Дата",        Дата);
	
	Запрос.Текст = "
	|ВЫБРАТЬ";
	
	ДобавитьЗапятую = Ложь;
	
	Для каждого Ресурс из Метаданные.РегистрыБухгалтерии[ИмяРегистра].Ресурсы Цикл
		ИмяРесурса = Ресурс.Имя;
		Если ДобавитьЗапятую Тогда
			Запрос.Текст = Запрос.Текст + ",";
			
		Иначе
			ДобавитьЗапятую = Истина;
		КонецЕсли;
		
		Запрос.Текст = Запрос.Текст + "
		|	ТаблицаОстатков." + ИмяРесурса + "ОстатокДт КАК " + ИмяРесурса + "ОстатокДт,
		|	ТаблицаОстатков." + ИмяРесурса + "ОстатокДт КАК " + ИмяРесурса + "ОстатокКт";
	КонецЦикла;
	
	Запрос.Текст = Запрос.Текст + "
	|ИЗ
	|	РегистрБухгалтерии." + ИмяРегистра + ".Остатки(&Дата, , , ) КАК ТаблицаОстатков
	|
	|ГДЕ
	|	ТаблицаОстатков.Счет = &СчетУчета И";

	Если не ЗначениеНеЗаполнено(Субконто[0]) Тогда
		Запрос.Текст = Запрос.Текст + "
		|	ТаблицаОстатков.Субконто1 = &Субконто1 И";
	КонецЕсли;

	Если не ЗначениеНеЗаполнено(Субконто[1]) Тогда
		Запрос.Текст = Запрос.Текст + "
		|	ТаблицаОстатков.Субконто2 = &Субконто2 И";
	КонецЕсли;

	Если не ЗначениеНеЗаполнено(Субконто[2]) Тогда
		Запрос.Текст = Запрос.Текст + "
		|	ТаблицаОстатков.Субконто3 = &Субконто3 И";
	КонецЕсли;

	Если не ЗначениеНеЗаполнено(Валюта) Тогда
		Запрос.Текст = Запрос.Текст + "
		|	ТаблицаОстатков.Валюта = &Валюта И";
	КонецЕсли;

	Запрос.Текст = Запрос.Текст + "
	|	ТаблицаОстатков.Организация = &Организация";

	Отчет = Запрос.Выполнить().Выгрузить();

	Результат = Новый Структура;

	Для каждого Колонка из Отчет.Колонки Цикл

		Если Отчет.Количество() > 0 Тогда
			Результат.Вставить(Колонка.Имя, Отчет.Итог(Колонка.Имя));

		Иначе
			Результат.Вставить(Колонка.Имя, 0);

		КонецЕсли;

	КонецЦикла;

	Возврат Результат;

КонецФункции

// Функция формирует представление заголовка документа
//
// Возвращаемое значение:
//  Строка - представление номера документа
//
Функция СформироватьЗаголовокДокумента(ДокументОбъект, НазваниеДокумента = "") Экспорт

	Возврат НазваниеДокумента + " № " + ПолучитьНомерНаПечать(ДокументОбъект)
	                          + " от " + Формат(ДокументОбъект.Дата, "ДФ='дд ММММ гггг'");

КонецФункции // СформироватьЗаголовокДокумента()
