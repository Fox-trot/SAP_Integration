﻿#Если Клиент Тогда
	
Перем НП Экспорт;
Перем ИмяРегистраБухгалтерии Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

////////////////////////////////////////////////////////////////////////////////
// ФОРМИРОВАНИЕ ПЕЧАТНОЙ ФОРМЫ ОТЧЕТА
//

// Формирует табличный документ с заголовком отчета
//
// Параметры:
//	Нет.
//
Функция СформироватьЗаголовок() Экспорт

	// Вывод заголовка, описателя периода и фильтров и шапки
	Если ДатаНач = '00010101000000' И ДатаКон = '00010101000000' Тогда

		ОписаниеПериода     = "Период: без ограничения.";

	Иначе

		Если ДатаНач = '00010101000000' ИЛИ ДатаКон = '00010101000000' Тогда

			ОписаниеПериода = "Период: " + Формат(ДатаНач, "ДФ = ""дд.ММ.гггг""; ДП = ""без ограничения""") 
							+ " - "      + Формат(ДатаКон, "ДФ = ""дд.ММ.гггг""; ДП = ""без ограничения""");

		Иначе

			ОписаниеПериода = "Период: " + ПредставлениеПериода(НачалоДня(ДатаНач), КонецДня(ДатаКон), "ФП = Истина");

		КонецЕсли;

	КонецЕсли;
	
	Макет = ПолучитьМакет("Макет");
	
	ЗаголовокОтчета = Макет.ПолучитьОбласть("Заголовок");

	НазваниеОрганизации = Организация.НаименованиеПолное;
	Если ПустаяСтрока(НазваниеОрганизации) Тогда
		НазваниеОрганизации = Организация;
	КонецЕсли;
	
	ЗаголовокОтчета.Параметры.НазваниеОрганизации = НазваниеОрганизации;
	
	ЗаголовокОтчета.Параметры.Заголовок = ЗаголовокОтчета();

	ЗаголовокОтчета.Параметры.ОписаниеПериода = ОписаниеПериода;

	ТекстСписокПоказателей = "Выводимые данные: сумма";
	Если ПоВалютам Тогда
		ТекстСписокПоказателей = ТекстСписокПоказателей + ", валютная сумма";
	КонецЕсли;

	ЗаголовокОтчета.Параметры.СписокПоказателей = ТекстСписокПоказателей;

	Возврат(ЗаголовокОтчета);
	
КонецФункции // СформироватьЗаголовок()

// Выполняет запрос и формирует табличный документ-результат отчета
// в соответствии с настройками, заданными значениями реквизитов отчета.
//
// Параметры:
//	ДокументРезультат - табличный документ, формируемый отчетом
//	ПоказыватьЗаголовок - признак видимости строк с заголовком отчета
//	ВысотаЗаголовка - параметр, через который возвращается высота заголовка в строках 
//
Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок = Истина, ВысотаЗаголовка = 0) Экспорт

	// Проверка на пустые значения
	Если ДатаНач > ДатаКон И ДатаКон <> '00010101000000' Тогда

		Предупреждение("Дата начала периода не может быть больше даты конца периода");
		Возврат;

	КонецЕсли;

	ДокументРезультат.Очистить();

	ОбластьЗаголовка = СформироватьЗаголовок();
	ВысотаЗаголовка = ОбластьЗаголовка.ВысотаТаблицы;
	ДокументРезультат.Вывести(ОбластьЗаголовка, 1);
	
	Если НЕ ЗначениеНеЗаполнено(ВысотаЗаголовка) Тогда
		ДокументРезультат.Область("R1:R" + ВысотаЗаголовка).Видимость = ПоказыватьЗаголовок;
	КонецЕсли;

	Макет  = ПолучитьМакет("Макет");
	
	Запрос = Новый Запрос;
	ТекстОтбор="";
	
	Если НЕ ЗначениеНеЗаполнено(Организация) Тогда
		Запрос.УстановитьПараметр("Организация", Организация);
		ТекстОтбор = ТекстОтбор + " И Организация =&Организация"
	КонецЕсли;
	
	ТекстОтборСчетДт="";
	ТекстОтборСчетКт="";
	ТекстОтборСчетДт=ТекстОтборСчетДт+?(НЕ ПоЗабалансовымСчетам, " И НЕ СчетДт.Забалансовый", "");
	ТекстОтборСчетКт=ТекстОтборСчетКт+?(НЕ ПоЗабалансовымСчетам, " И НЕ СчетКт.Забалансовый", "");
	
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ХозрасчетныйОборотыДтКт.СчетДт КАК СчетДт,
	|	ХозрасчетныйОборотыДтКт.СчетКт КАК СчетКт,
	|	ХозрасчетныйОборотыДтКт.ВалютаДт КАК ВалютаДт,
	|	ХозрасчетныйОборотыДтКт.ВалютаДт.Представление КАК ВалютаДтПредставление,
	|	ХозрасчетныйОборотыДтКт.ВалютаКт КАК ВалютаКт,
	|	ХозрасчетныйОборотыДтКт.ВалютаКт.Представление КАК ВалютаКтПредставление,
	|	ХозрасчетныйОборотыДтКт.СчетДт.Представление КАК СчетДтПредставление,
	|	ХозрасчетныйОборотыДтКт.СчетКт.Представление КАК СчетКтПредставление,
	|	ХозрасчетныйОборотыДтКт.СчетДт.Валютный КАК СчетДтВалютный,
	|	ХозрасчетныйОборотыДтКт.СчетКт.Валютный КАК СчетКтВалютный,
	|	ХозрасчетныйОборотыДтКт.СуммаОборот КАК СуммаОборот,
	|	ХозрасчетныйОборотыДтКт.ВалютнаяСуммаОборотДт КАК ВалютнаяСуммаОборотДт,
	|	ХозрасчетныйОборотыДтКт.ВалютнаяСуммаОборотКт КАК ВалютнаяСуммаОборотКт
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(&ДатаНач, &ДатаКон, , " 
	+ Сред(ТекстОтборСчетДт, 3)+ ", , " 
	+ Сред(ТекстОтборСчетКт, 3)+ ", , "
	+ Сред(ТекстОтбор, 3) +"
	|) КАК ХозрасчетныйОборотыДтКт
	|
	|ИТОГИ СУММА(СуммаОборот), СУММА(ВалютнаяСуммаОборотДт), СУММА(ВалютнаяСуммаОборотКт) ПО ОБЩИЕ,
	|	СчетДт ИЕРАРХИЯ,
	|	СчетКт ИЕРАРХИЯ,
	|	ВалютаДт, ВалютаКт
	|АВТОУПОРЯДОЧИВАНИЕ";
	
	Запрос.УстановитьПараметр("ДатаНач", ДатаНач);
	
	Если ДатаКон <> '00010101000000' Тогда
		Запрос.УстановитьПараметр("ДатаКон", КонецДня(ДатаКон));
	Иначе
		Запрос.УстановитьПараметр("ДатаКон", ДатаКон);
	КонецЕсли;
	
	Результат = Запрос.Выполнить();
	
	СоотвСчетаВерхнегоУровня = Новый Соответствие;
	Если Не ПоСубсчетам Тогда
		ЗапросСчетаВерх = Новый Запрос(
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Хозрасчетный.Ссылка
		|ИЗ
		|	ПланСчетов.Хозрасчетный КАК Хозрасчетный
		|
		|ГДЕ
		|	Хозрасчетный.Родитель = &ПустойРодитель");
		ЗапросСчетаВерх.УстановитьПараметр("ПустойРодитель", ПланыСчетов.Хозрасчетный.ПустаяСсылка());
		ВыборкаСчетов=ЗапросСчетаВерх.Выполнить().Выбрать();
		Пока ВыборкаСчетов.Следующий() Цикл
			СоотвСчетаВерхнегоУровня.Вставить(ВыборкаСчетов.Ссылка, ВыборкаСчетов.Ссылка)
		КонецЦикла;
	КонецЕсли;
	
	ОблНачалоТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы|ПерваяКолонка");
	ОблСчетКт = Макет.ПолучитьОбласть("ШапкаТаблицы|Оборот");
	ОблСчетДт = Макет.ПолучитьОбласть("СтрокаСчет|ПерваяКолонка");
	ОблОборот = Макет.ПолучитьОбласть("СтрокаСчет|Оборот");
	
	// Макеты для валютных счетов
	ОблСчетКтВал = Макет.ПолучитьОбласть("ШапкаТаблицы|ОборотВалюта");
	ОблСчетДтВал = Макет.ПолучитьОбласть("СтрокаСчетВалюта|ПерваяКолонка");
	
	// Если валютный счет Кт
	ОблОборотКтВал = Макет.ПолучитьОбласть("СтрокаСчет|ОборотВалюта");
	// Если валютный счет Дт
	ОблОборотДтВал = Макет.ПолучитьОбласть("СтрокаСчетВалюта|Оборот");
	// Если валютные оба счета
	ОблОборотДтКтВал = Макет.ПолучитьОбласть("СтрокаСчетВалюта|ОборотВалюта");
	ОблИтогоОборот = Макет.ПолучитьОбласть("СтрокаСчет|ИтогоОборотДт");
	ОблИтогоОборотДтВал = Макет.ПолучитьОбласть("СтрокаСчетВалюта|ИтогоОборотДт");
	
	СоответствиеСчетовКтИВалют = Новый Соответствие;
	
	ДокументРезультат.НачатьАвтогруппировкуКолонок();
	
	// Вывод шапки таблицы
	ДокументРезультат.Вывести(ОблНачалоТаблицы,0);
	
	ВыборкаСчетаКт=Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "СчетКт", "Все");
	Пока ВыборкаСчетаКт.Следующий() Цикл
		
		Если НЕ ПоСубсчетам И СоотвСчетаВерхнегоУровня[ВыборкаСчетаКт.СчетКт]=Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		СчетКтВалютный = ?(ВыборкаСчетаКт.СчетКтВалютный=Истина, Истина, Ложь);
		
		ВыводимаяОбласть = ОблСчетКт;
		
		ВыводимаяОбласть.Параметры.Заполнить(ВыборкаСчетаКт);
		ДокументРезультат.Присоединить(ВыводимаяОбласть, ВыборкаСчетаКт.Уровень()+1);
		
		// Вывод валют по кредиту
		Если СчетКтВалютный И ПоВалютам Тогда
			
			ВыборкаВалютыКт=ВыборкаСчетаКт.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "ВалютаКт");
			
			СоответствиеВалютКт = Новый Соответствие;
			
			Пока ВыборкаВалютыКт.Следующий() Цикл
				
				ВыводимаяОбласть = ОблСчетКтВал;
				
				ВыводимаяОбласть.Параметры.Заполнить(ВыборкаВалютыКт);
				
				// Параметры для расшифровки
				ВыводимаяОбласть.Параметры.Расшифровка = Новый Структура("СчетКт, ВалютаКт", ВыборкаВалютыКт.СчетКт, ВыборкаВалютыКт.ВалютаКт);
				
				ДокументРезультат.Присоединить(ВыводимаяОбласть, ВыборкаВалютыКт.Уровень()+1);
				
				СоответствиеВалютКт.Вставить(ВыборкаВалютыКт.ВалютаКт,1);
				
			КонецЦикла;
			
			// Запомним валюты, по которым есть итоги на данном счете, чтобы при выводить нужное количество ячеек в строках
			СоответствиеСчетовКтИВалют.Вставить(ВыборкаСчетаКт.СчетКт, СоответствиеВалютКт);
		КонецЕсли;

	КонецЦикла;
	ДокументРезультат.Присоединить(Макет.ПолучитьОбласть("ШапкаТаблицы|ИтогоОборотДт"), 0);
	ДокументРезультат.ЗакончитьАвтогруппировкуКолонок();
	
	// Вывод строк таблицы
	ДокументРезультат.НачатьАвтогруппировкуСтрок();
	
	ВыборкаСчетаДт = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "СчетДт");
	
	Пока ВыборкаСчетаДт.Следующий() Цикл
		
		Если НЕ ПоСубсчетам И СоотвСчетаВерхнегоУровня[ВыборкаСчетаДт.СчетДт]=Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		СчетДтВалютный = ?(ВыборкаСчетаДт.СчетДтВалютный=Истина, Истина, Ложь);
		
		ОблСчетДт.Параметры.Заполнить(ВыборкаСчетаДт);
		ДокументРезультат.Вывести(ОблСчетДт, ВыборкаСчетаДт.Уровень()+1);
		
		ВывестиОборот(ВыборкаСчетаДт, СоотвСчетаВерхнегоУровня, Ложь, СоответствиеСчетовКтИВалют, ДокументРезультат, ОблОборотДтКтВал, ОблОборотДтВал, ОблОборотКтВал, ОблОборот, ОблИтогоОборот, ОблИтогоОборотДтВал);
		
		// Вывод валют по дебету
		Если СчетДтВалютный И ПоВалютам Тогда
			
			ВыборкаВалютыДт=ВыборкаСчетаДт.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "ВалютаДт");
			
			Пока ВыборкаВалютыДт.Следующий() Цикл
				
				ВыводимаяОбласть = ОблСчетДтВал;
				
				ВыводимаяОбласть.Параметры.Заполнить(ВыборкаВалютыДт);
				
				// Параметры для расшифровки
				ВыводимаяОбласть.Параметры.Расшифровка = Новый Структура("СчетДт, ВалютаДт", ВыборкаВалютыДт.СчетДт, ВыборкаВалютыДт.ВалютаДт);
				
				ДокументРезультат.Вывести(ВыводимаяОбласть, ВыборкаВалютыДт.Уровень()+1);
				
				ВывестиОборот(ВыборкаВалютыДт, СоотвСчетаВерхнегоУровня, Истина, СоответствиеСчетовКтИВалют, ДокументРезультат, ОблОборотДтКтВал, ОблОборотДтВал, ОблОборотКтВал, ОблОборот, ОблИтогоОборот, ОблИтогоОборотДтВал);
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЦикла;
	
	// Вывод итога
	ВыборкаОборот = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Общие");
	ВыборкаОборот.Следующий();
	ДокументРезультат.Вывести(Макет.ПолучитьОбласть("ИтогоОборотКт|ПерваяКолонка"), 0);
	ВывестиОборот(ВыборкаОборот, СоотвСчетаВерхнегоУровня, Ложь, СоответствиеСчетовКтИВалют, ДокументРезультат, ОблОборотДтКтВал, ОблОборотДтВал, ОблОборотКтВал, ОблОборот, ОблИтогоОборот, ОблИтогоОборотДтВал);
	
	ДокументРезультат.ЗакончитьАвтогруппировкуСтрок();
	
	ТолстаяЛиния = ОблНачалоТаблицы.Область(2, 2).ГраницаСверху;
	
	ДокументРезультат.Область(ВысотаЗаголовка+2, 2, ДокументРезультат.ВысотаТаблицы, ДокументРезультат.ШиринаТаблицы).Обвести(ТолстаяЛиния, ТолстаяЛиния, ТолстаяЛиния, ТолстаяЛиния);
		
	// Заполним общую расшифровку:
	СтруктураНастроекОтчета = Новый Структура;

	СтруктураНастроекОтчета.Вставить("ДатаНач", ДатаНач);
	СтруктураНастроекОтчета.Вставить("ДатаКон", ДатаКон);
	СтруктураНастроекОтчета.Вставить("Организация", Организация);
	СтруктураНастроекОтчета.Вставить("ПоказыватьЗаголовок", ПоказыватьЗаголовок);

	ДокументРезультат.Область(1,1).Расшифровка = СтруктураНастроекОтчета;

	// Зафиксируем заголовок отчета
	ДокументРезультат.ФиксацияСверху = ВысотаЗаголовка + 2;
	// Зафиксируем первую колонку отчета
	ДокументРезультат.ФиксацияСлева = 2;

	// Первую колонку не печатаем
	ДокументРезультат.ОбластьПечати = ДокументРезультат.Область(1,2,ДокументРезультат.ВысотаТаблицы,ДокументРезультат.ШиринаТаблицы);
	
	// Присвоим имя для сохранения параметров печати табличного документа
	ДокументРезультат.ИмяПараметровПечати = "Шахматка"+ИмяРегистраБухгалтерии;

КонецПроцедуры // СформироватьОтчет()

// Обработка расшифровки
//
// Параметры:
//	Нет.
//
Процедура ОбработкаРасшифровкиСтандартногоОтчета(Расшифровка) Экспорт
	
	Отчет = Отчеты.ОтчетПоПроводкамХозрасчетный.Создать();
	
	ФормаОтчета = Отчет.ПолучитьФорму(, , Новый УникальныйИдентификатор());
	
	Попытка
		
		Отчет.Настроить(Расшифровка);
		
		ФормаОтчета.ПоказыватьЗаголовок = Расшифровка["ПоказыватьЗаголовок"];
		
		ФормаОтчета.ОбновитьОтчет();
		
	Исключение
	КонецПопытки;
	
	ФормаОтчета.Открыть();
	
КонецПроцедуры // ОбработкаРасшифровкиСтандартногоОтчета()

Процедура ВывестиОборот(ВыборкаСчетаДт, СоотвСчетаВерхнегоУровня, СчетДтПоВалюте, СоответствиеСчетовКтИВалют, ДокументРезультат, ОблОборотДтКтВал, ОблОборотДтВал, ОблОборотКтВал, ОблОборот, ОблИтогоОборот, ОблИтогоОборотДтВал)
	
	ВыборкаОборот = ВыборкаСчетаДт.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "СчетКт", "Все");
	Пока ВыборкаОборот.Следующий() Цикл
		
		Если НЕ ПоСубсчетам И СоотвСчетаВерхнегоУровня[ВыборкаОборот.СчетКт]=Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		СчетКтВалютный = ?(ВыборкаОборот.СчетКтВалютный=Истина, Истина, Ложь);
		
		Если НЕ СчетДтПоВалюте Тогда
			ВыводимаяОбласть=ОблОборот;
		Иначе
			ВыводимаяОбласть=ОблОборотДтВал;
		КонецЕсли;
		
		ВыводимаяОбласть.Параметры.Заполнить(ВыборкаОборот);
		ДокументРезультат.Присоединить(ВыводимаяОбласть);
		
		// Вывод валют по кредиту
		Если СчетКтВалютный И ПоВалютам Тогда
			
			ВыборкаВалютыКт=ВыборкаОборот.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "ВалютаКт", "Все");
			
			Если СчетДтПоВалюте Тогда
				ВыводимаяОбласть=ОблОборотДтКтВал;
			ИначеЕсли НЕ СчетДтПоВалюте Тогда
				ВыводимаяОбласть=ОблОборотКтВал;
			КонецЕсли;
			
			Пока ВыборкаВалютыКт.Следующий() Цикл
				
				// Не выводим ячейки для тех валют, по которым не было итогов
				Если СоответствиеСчетовКтИВалют[ВыборкаВалютыКт.СчетКт][ВыборкаВалютыКт.ВалютаКт]=Неопределено Тогда
					Продолжить;
				КонецЕсли;
				
				ВыводимаяОбласть.Параметры.Заполнить(ВыборкаВалютыКт);
				
				ДокументРезультат.Присоединить(ВыводимаяОбласть, ВыборкаВалютыКт.Уровень()+1);
				
			КонецЦикла;
		КонецЕсли;
		
	КонецЦикла;
	
	// Вывод итога
	Если НЕ СчетДтПоВалюте Тогда
		ВыводимаяОбласть=ОблИтогоОборот;
	Иначе
		ВыводимаяОбласть=ОблИтогоОборотДтВал;
	КонецЕсли;
	ВыводимаяОбласть.Параметры.Заполнить(ВыборкаСчетаДт);
	ДокументРезультат.Присоединить(ВыводимаяОбласть, ВыборкаСчетаДт.Уровень()+1);
	
	
КонецПроцедуры // ВывестиОборот()

Функция ЗаголовокОтчета() Экспорт
	Возврат "Шахматная оборотная ведомость";
КонецФункции // ЗаголовокОтчета()

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
// 

НП = Новый НастройкаПериода;
НП.ВариантНастройки = ВариантНастройкиПериода.Период;

// Константа - имя регистра бухгалтерии
ИмяРегистраБухгалтерии = "Хозрасчетный";

#КонецЕсли