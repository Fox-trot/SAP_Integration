﻿Перем мВалютаРегламентированногоУчета Экспорт;
Перем МетаданныеПоДокументам Экспорт;

#Если Клиент Тогда
	

// Настройка периода
Перем НП Экспорт;


// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

Функция ПечатьАктаСверки()	

	ТабДок = Новый ТабличныйДокумент;
	ТабДок.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_АктСверкиВзаиморасчетов_АктСверки";
	Макет  = ПолучитьМакет("АктСверки");

	ОбластьЗаголовок    = Макет.ПолучитьОбласть("Заголовок");
	ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьНачОстатки   = Макет.ПолучитьОбласть("НачОстатки");
	ОбластьДоговор      = Макет.ПолучитьОбласть("Договор");
	ОбластьДоговорИтоги = Макет.ПолучитьОбласть("ДоговорИтоги");
	ОбластьОбороты      = Макет.ПолучитьОбласть("Обороты");
	ОбластьОборотыИтог  = Макет.ПолучитьОбласть("ОборотыИтог");
	ОбластьКонОстатки   = Макет.ПолучитьОбласть("КонОстатки");
	ОбластьПодвал       = Макет.ПолучитьОбласть("Подвал");
	
	СведенияОбОрганизации    = СведенияОЮрФизЛице(Организация,, Дата);
	ПредставлениеОрганизации = ОписаниеОрганизации(СведенияОбОрганизации, "ОрганизацияНаименование,");
	
	СведенияОКонтрагенте     = СведенияОЮрФизЛице(Контрагент,, Дата);
	ПредставлениеКонтрагента = ОписаниеОрганизации(СведенияОКонтрагенте, "КонтрагентНаименование,");
	
	ОбластьЗаголовок.Параметры.НазваниеОрганизации     = ПредставлениеОрганизации;
	ОбластьЗаголовок.Параметры.НаименованиеКонтрагента = ПредставлениеКонтрагента;
	Если ДатаНачала = '00010101' Тогда
		Если ПоДаннымОрганизации.Количество()>0 Тогда
			ДатаНачалаОтчета=ПоДаннымОрганизации[0].Дата;
		Иначе
			ДатаНачалаОтчета = '00010101';
		КонецЕсли;
	Иначе
		ДатаНачалаОтчета = ДатаНачала;
	КонецЕсли;

	ОписаниеПериода = "за период: " + ПредставлениеПериода(НачалоДня(ДатаНачалаОтчета), КонецДня(ДатаОкончания), "ФП = Истина");
	
	ТекстЗаголовка = "взаимных расчетов " + ОписаниеПериода  + Символы.ПС
					+ "между " + ПредставлениеОрганизации + Символы.ПС + "и " + ПредставлениеКонтрагента;
	Если ЗначениеЗаполнено(ДоговорКонтрагента) Тогда
		Если ДоговорКонтрагента.ЭтоГруппа Тогда
			МассивДоговоров = ПоДаннымОрганизации.ВыгрузитьКолонку("Договор");
			МассивДоговоров = УдалитьПовторяющиесяЭлементыМассива(МассивДоговоров);
			ТекстЗаголовка = ТекстЗаголовка + Символы.ПС + "по договору ";
			ТекстДоговоров = "";
			Для каждого ТекДоговор Из МассивДоговоров Цикл
				ТекстДоговоров = ТекстДоговоров + ?(ПустаяСтрока(ТекстДоговоров), "", ", ") + ТекДоговор;
			КонецЦикла; 
			ТекстЗаголовка = ТекстЗаголовка + ТекстДоговоров;
		Иначе
		    ТекстЗаголовка = ТекстЗаголовка + Символы.ПС + "по договору " + ДоговорКонтрагента;
		КонецЕсли;
	КонецЕсли;
	
	ОбластьЗаголовок.Параметры.ТекстЗаголовка = ТекстЗаголовка;
	
	ДанныеПредставителяОрганизации = ДанныеФизЛица(Организация, ПредставительОрганизации.ФизическоеЛицо, Дата);
	ФИОПредставителя = ?(НЕ ЗначениеЗаполнено(ДанныеПредставителяОрганизации.Фамилия),"",ДанныеПредставителяОрганизации.Фамилия
					+ ?(НЕ ЗначениеЗаполнено(ДанныеПредставителяОрганизации.Имя),""," "+ДанныеПредставителяОрганизации.Имя)
					+ ?(НЕ ЗначениеЗаполнено(ДанныеПредставителяОрганизации.Отчество),""," "+ДанныеПредставителяОрганизации.Отчество));
	
	СтрЗаголовокТаблица = "Мы, нижеподписавшиеся, " + ?(НЕ ЗначениеЗаполнено(ДанныеПредставителяОрганизации.Должность),"________________",ДанныеПредставителяОрганизации.Должность) + " " + ПредставлениеОрганизации
				+ " " + ?(ФИОПредставителя<>"",ФИОПредставителя,"_______________________") + ", с одной стороны, "
				+ "и " + ?(НЕ ЗначениеЗаполнено(ПредставительКонтрагента.Должность),"________________",ПредставительКонтрагента.Должность) + " " + ПредставлениеКонтрагента + " " 
				+ ?(НЕ ЗначениеЗаполнено(ПредставительКонтрагента),"_______________________",ПредставительКонтрагента) + ", с другой стороны, "
				+ "составили настоящий акт сверки в том, что состояние взаимных расчетов по данным учета следующее:";
	
	ОбластьЗаголовок.Параметры.СтрЗаголовокТаблица = СтрЗаголовокТаблица;
	ОбластьЗаголовок.Параметры.ВалютаДокумента = ВалютаДокумента;
	
	ТабДок.Очистить();
	ТабДок.Вывести(ОбластьЗаголовок);
	ТабДок.Вывести(ОбластьШапкаТаблицы);
	
	ОбластьНачОстатки.Параметры.СуммаНачальныйОстатокДт = ?(ОстатокНаНачало > 0, ОстатокНаНачало, 0);
	ОбластьНачОстатки.Параметры.СуммаНачальныйОстатокКт = ?(ОстатокНаНачало < 0, -ОстатокНаНачало, 0);
	ТабДок.Вывести(ОбластьНачОстатки);
	
	ОборотыДт = 0;
	ОборотыКт = 0;
	ОборотыДтКонтр = 0;
	ОборотыКтКонтр = 0;

		
	Если ПоДаннымОрганизации.Количество()>0 ИЛИ ПоДаннымКонтрагента.Количество()>0 Тогда
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.Ссылка);
		Запрос.Текст =	
		"ВЫБРАТЬ
		|	ВлЗапрос.Договор КАК Договор,
		|	ВлЗапрос.Дата КАК Дата,
		|	ВлЗапрос.Документ,
		|	ВлЗапрос.Представление,
		|	ВлЗапрос.ДатаК,
		|	ВлЗапрос.ПредставлениеК,
		|	Дебет как СуммаДогДт,
		|	Кредит как СуммаДогКт,
		|	ДебетК как СуммаДогДтКонтр,
		|	КредитК как СуммаДогКтКонтр	
		|Из
		|	(Выбрать"
		+?(РазбитьПоДоговорам,"
		|		ПоДаннымОрганизации.Договор КАК Договор,","
		|		NULL КАК Договор,")
		+"	
		|		ПоДаннымОрганизации.Дата как Дата,
		|		NUll как ДатаК,
		|		ПоДаннымОрганизации.Документ КАК Документ,
		|		ПоДаннымОрганизации.Представление КАК Представление,
		|		NULL КАК ПредставлениеК,
		|		ПоДаннымОрганизации.Дебет КАК Дебет,
		|		ПоДаннымОрганизации.Кредит КАК Кредит,
		|		0 КАК ДебетК,
		|		0 КАК КредитК
		|	ИЗ
		|		Документ.АктСверкиВзаиморасчетов.ПоДаннымОрганизации КАК ПоДаннымОрганизации
		|	Где
		|		ПоДаннымОрганизации.Ссылка = &ТекущийДокумент
		|
		|	ОБЪЕДИНИТЬ ВСЕ
		|   
		|	Выбрать"
		+?(РазбитьПоДоговорам,"
		|		ПоДаннымКонтрагента.Договор,","
		|		NULL КАК Договор,")
		+"	
		|		NULL,
		|		ПоДаннымКонтрагента.Дата,
		|		NULL,
		|		NULL,
		|		ПоДаннымКонтрагента.Представление,
		|		0,
		|		0,
		|		ПоДаннымКонтрагента.Дебет,
		|		ПоДаннымКонтрагента.Кредит
		|
		|	ИЗ
		|		Документ.АктСверкиВзаиморасчетов.ПоДаннымКонтрагента КАК ПоДаннымКонтрагента
		|	Где
		|		ПоДаннымКонтрагента.Ссылка = &ТекущийДокумент
		|     
		|     
		|)	КАК ВлЗапрос
		|
		|	ИТОГИ
		|		СУММА(СуммаДогДт),
		|		СУММА(СуммаДогКт),
		|		СУММА(СуммаДогДтКонтр),
		|		СУММА(СуммаДогКтКонтр)
		|	ПО
		|		Общие,Договор";
		
		Результат = Запрос.Выполнить();		
		
		ОбходПоОбщимИтогам = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Общие");
		ОбходПоОбщимИтогам.Следующий();	
		
		ОборотыДт = ОбходПоОбщимИтогам.СуммаДогДт;
		ОборотыКт = ОбходПоОбщимИтогам.СуммаДогКт;
		ОборотыДтКонтр = ОбходПоОбщимИтогам.СуммаДогДтКонтр;
		ОборотыКтКонтр = ОбходПоОбщимИтогам.СуммаДогКтКонтр;

		
		ОбходПоДоговорам = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Договор");
		Пока ОбходПоДоговорам.Следующий() Цикл
			
			Если РазбитьПоДоговорам Тогда
				//Выводим заголовок с договором
				ОбластьДоговор.Параметры.Договор = ОбходПоДоговорам.Договор;
				ОбластьДоговор.Параметры.Регистратор = ОбходПоДоговорам.Договор;
				ТабДок.Вывести(ОбластьДоговор);
				ОбходПоДокументам=ОбходПоДоговорам.Выбрать();
			Иначе
				ОбходПоДокументам=Результат.Выбрать();
			КонецЕсли;		
			
			//Создадим список документов по организации и контрагенту
			СписокДокументов = новый массив;
			СписокДокументовК = новый массив;
			Пока ОбходПоДокументам.Следующий() Цикл
				Если ОбходПоДокументам.Дата<>NULL Тогда
					СписокДокументов.Добавить(новый структура("ДатаДокумента,РегистраторПредставление,Регистратор,СуммаОборотДт,СуммаОборотКт",
					ОбходПоДокументам.Дата,ОбходПоДокументам.Представление,ОбходПоДокументам.Документ,ОбходПоДокументам.СуммаДогДт,ОбходПоДокументам.СуммаДогКт));				
				КонецЕсли;
				
				Если ОбходПоДокументам.ДатаК<>NULL Тогда
					СписокДокументовК.Добавить(новый структура("ДатаДокументаКонтр,РегистраторПредставлениеКонтр,СуммаОборотДтКонтр,СуммаОборотКтКонтр",
					ОбходПоДокументам.ДатаК,ОбходПоДокументам.ПредставлениеК,ОбходПоДокументам.СуммаДогДтКонтр,ОбходПоДокументам.СуммаДогКтКонтр));				
				КонецЕсли; 
			КонецЦикла;
			
			//Для упрощения вывода, сравним списки по количеству элементов, добавив пустые
			МаксИндекс = Макс(СписокДокументов.Количество(), СписокДокументовК.Количество())-1;
			МинИндекс = Мин(СписокДокументов.Количество(), СписокДокументовК.Количество())-1;
			Если СписокДокументов.Количество()<СписокДокументовК.Количество() Тогда
				Для инд = МинИндекс По МаксИндекс-1 Цикл
					СписокДокументов.Добавить(новый структура("ДатаДокумента,РегистраторПредставление,Регистратор,СуммаОборотДт,СуммаОборотКт","","","","",""));
				КонецЦикла;
			ИначеЕсли СписокДокументов.Количество()>СписокДокументовК.Количество() Тогда 
				Для инд = МинИндекс По МаксИндекс-1 Цикл
					СписокДокументовК.Добавить(новый структура("ДатаДокументаКонтр,РегистраторПредставлениеКонтр,СуммаОборотДтКонтр,СуммаОборотКтКонтр","","","",""));
				КонецЦикла;			
			КонецЕсли;
			
			Для Инд = 0 По МаксИндекс Цикл
				ОбластьОбороты.Параметры.Заполнить(СписокДокументов[Инд]);
				ОбластьОбороты.Параметры.Заполнить(СписокДокументовК[Инд]);			
				ТабДок.Вывести(ОбластьОбороты);
			КонецЦикла;
			
			Если РазбитьПоДоговорам Тогда
				//Выводим итоги по каждому договору
				ОбластьДоговорИтоги.Параметры.Заполнить(ОбходПоДоговорам);		
				ТабДок.Вывести(ОбластьДоговорИтоги);	
			Иначе
				Прервать;
			КонецЕсли;
			
		КонецЦикла;  
		
		ОбластьОборотыИтог.Параметры.СуммаОборотДт      = ОборотыДт;
		ОбластьОборотыИтог.Параметры.СуммаОборотКт      = ОборотыКт;
		Если СверкаСогласована тогда
			ОбластьОборотыИтог.Параметры.СуммаОборотДтКонтр = ОборотыДтКонтр;
			ОбластьОборотыИтог.Параметры.СуммаОборотКтКонтр = ОборотыКтКонтр;
		КонецЕсли;
		ТабДок.Вывести(ОбластьОборотыИтог);
		
	КонецЕсли;
	      
	ОстатокНаКонец = ОстатокНаНачало + ОборотыДт -  ОборотыКт;
	ОбластьКонОстатки.Параметры.СуммаКонечныйОстатокДт = ?(ОстатокНаКонец > 0, ОстатокНаКонец, 0);
	ОбластьКонОстатки.Параметры.СуммаКонечныйОстатокКт = ?(ОстатокНаКонец < 0, -ОстатокНаКонец, 0);
	
	Если СверкаСогласована тогда
		ОстатокНаКонецК = ОстатокНаНачало - ОборотыДтКонтр +  ОборотыКтКонтр;
		ОбластьКонОстатки.Параметры.СуммаКонечныйОстатокКтКонтр = ?(ОстатокНаКонецК > 0, ОстатокНаКонецК, 0);
		ОбластьКонОстатки.Параметры.СуммаКонечныйОстатокДтКонтр = ?(ОстатокНаКонецК < 0, -ОстатокНаКонецК, 0);
	КонецЕсли;
	
	ТабДок.Вывести(ОбластьКонОстатки);
	
	// Результаты сверки
  	Если НЕ ЗначениеЗаполнено(ДатаОкончания) Тогда
   	    РезультатыСверки = "<не указана дата сверки>";
   	ИначеЕсли НЕ ЗначениеЗаполнено(Контрагент) Тогда
   	    РезультатыСверки = "<не указан контрагент>";
   	Иначе
		РезультатыСверки = "на " + Формат(ДатаОкончания, "ДФ=dd.MM.yyyy") + " задолженность ";
			
	   	Если ОстатокНаКонец > 0 Тогда
			РезультатыСверки = РезультатыСверки + "в пользу " + ПредставлениеОрганизации + " " 
								+ Формат(ОстатокНаКонец, "ЧЦ=21; ЧДЦ=2") + " " 
								+ строка(ВалютаДокумента)
								+" ("+СформироватьСуммуПрописью(ОстатокНаКонец, ВалютаДокумента)+")" ;
	
	   	ИначеЕсли ОстатокНаКонец < 0 Тогда
			РезультатыСверки = РезультатыСверки + "в пользу " + ПредставлениеКонтрагента + " " 
								+ Формат(-ОстатокНаКонец, "ЧЦ=21; ЧДЦ=2") + " " 
								+ строка(ВалютаДокумента)
								+" ("+СформироватьСуммуПрописью(-ОстатокНаКонец, ВалютаДокумента)+")" ;
	
	   	Иначе
	   		РезультатыСверки = РезультатыСверки + "отсутствует.";
	   	КонецЕсли;
	КонецЕсли;
	ОбластьПодвал.Параметры.РезультатыСверки = РезультатыСверки;
	
	Если СверкаСогласована тогда
		ОбластьПодвал.Параметры.ПоДаннымКонтрагента = "По данным " + ПредставлениеКонтрагента;
		
	  	Если НЕ ЗначениеЗаполнено(ДатаОкончания) Тогда
	   	    РезультатыСверки = "<не указана дата сверки>";
	   	ИначеЕсли НЕ ЗначениеЗаполнено(Контрагент) Тогда
	   	    РезультатыСверки = "<не указан контрагент>";
	   	Иначе
			РезультатыСверки = "на " + Формат(ДатаОкончания, "ДФ=dd.MM.yyyy") + " задолженность ";
				
		   	Если ОстатокНаКонецК > 0 Тогда
				РезультатыСверки = РезультатыСверки + "в пользу " + ПредставлениеОрганизации + " " 
									+ Формат(ОстатокНаКонецК, "ЧЦ=21; ЧДЦ=2") + " " 
									+ строка(ВалютаДокумента)
									+" ("+СформироватьСуммуПрописью(ОстатокНаКонецК, ВалютаДокумента)+")" ;

		
		   	ИначеЕсли ОстатокНаКонецК < 0 Тогда
				РезультатыСверки = РезультатыСверки + "в пользу " + ПредставлениеКонтрагента + " " 
									+ Формат(-ОстатокНаКонецК, "ЧЦ=21; ЧДЦ=2") + " " 
									+ строка(ВалютаДокумента)
									+" ("+СформироватьСуммуПрописью(-ОстатокНаКонецК, ВалютаДокумента)+")" ;

		
		   	Иначе
		   		РезультатыСверки = РезультатыСверки + "отсутствует.";
		   	КонецЕсли;
	   	КонецЕсли;
		
		ОбластьПодвал.Параметры.РезультатыСверкиК = РезультатыСверки;
		
		Если Расхождение<>0 Тогда                                                                                                                                                                                                                                                               
			 ИтогСверки = "В результате сверки выявлено расхождение информации о состоянии расчетов в размере "
			 			+Формат(?(Расхождение>0,1,-1)*Расхождение, "ЧЦ=21; ЧДЦ=2") 
						+" "+ Строка(ВалютаДокумента)
						+" ("+СформироватьСуммуПрописью(?(Расхождение>0,1,-1)*Расхождение, ВалютаДокумента)+")" ;
			 ОбластьПодвал.Параметры.ИтогСверки = Символы.ПС+ ИтогСверки+Символы.ПС+" ";
		КонецЕсли; 
	КонецЕсли;
	              
	ОбластьПодвал.Параметры.НазваниеОрганизации     = ПредставлениеОрганизации;
	ОбластьПодвал.Параметры.НаименованиеКонтрагента = ПредставлениеКонтрагента;
	
	ОбластьПодвал.Параметры.Должность  = ?(НЕ ЗначениеЗаполнено(ДанныеПредставителяОрганизации.Должность),"________________",ДанныеПредставителяОрганизации.Должность);
	ОбластьПодвал.Параметры.ДолжностьК = ?(НЕ ЗначениеЗаполнено(ПредставительКонтрагента.Должность),"________________",ПредставительКонтрагента.Должность);
	
	ОбластьПодвал.Параметры.ФИОПредставителя  = "("+?(НЕ ЗначениеЗаполнено(ДанныеПредставителяОрганизации),"_______________________",ДанныеПредставителяОрганизации.Представление)+")";
	ОбластьПодвал.Параметры.ФИОПредставителяК = "("+?(НЕ ЗначениеЗаполнено(ПредставительКонтрагента),"_______________________",ФамилияИнициалыФизЛица(ПредставительКонтрагента.Фамилия + " " + ПредставительКонтрагента.Имя + " " + ПредставительКонтрагента.Отчество))+")";
	
	ТабДок.Вывести(ОбластьПодвал);
	
	Возврат ТабДок;
	
КонецФункции

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходимое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	// Получить экземпляр документа на печать
	Если ИмяМакета = "АктСверки" Тогда
		
		ТабДокумент = ПечатьАктаСверки();
		
	КонецЕсли;
	
	Если ТабДокумент <> Ложь Тогда
		НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, СформироватьЗаголовокДокумента(ЭтотОбъект, ЭтотОбъект.Метаданные().Представление()), НепосредственнаяПечать);
	КонецЕсли;
	
КонецПроцедуры // Печать

Функция ПолучитьВходящийДокумент(Док)
	
	ВходящийДокумент="";
	
	Если ТипЗнч(Док)=Тип("ДокументСсылка.ПоступлениеНоменклатуры")
     или ТипЗнч(Док)=Тип("ДокументСсылка.ПоступлениеНоменклатурыВалютныйСписками")
     или ТипЗнч(Док)=Тип("ДокументСсылка.ПоступлениеНоменклатурыПродаж")
     или ТипЗнч(Док)=Тип("ДокументСсылка.ПоступлениеНоменклатурыПродажВалютныйСписками")
     или ТипЗнч(Док)=Тип("ДокументСсылка.ПоступлениеНоменклатурыСПереработки")
		Тогда
		ВходящийДокумент = СокрЛП(Док.ПриходныйДокумент);	
	КонецЕсли;
	
	Возврат ВходящийДокумент;
	
КонецФункции	

// Заполнение таблицы "По данным организации" по информации из бухгалтерского учета
Процедура ЗаполнитьПоДаннымБухгалтерскогоУчета(ФильтрСписокСчетов = неопределено) Экспорт
	
	КоличествоСчетов = СписокСчетов.Количество();
	Если ФильтрСписокСчетов = неопределено Тогда
		ФильтрСписокСчетов = Новый массив();
		Для каждого СтрокаСчета Из СписокСчетов Цикл
			Если НЕ ЗначениеЗаполнено(СтрокаСчета.Счет) или СтрокаСчета.УчаствуетВРасчетах = Ложь Тогда
				Продолжить;
			Иначе
				ФильтрСписокСчетов.Добавить(СтрокаСчета.Счет);
			КонецЕсли; 
		КонецЦикла; 
		
		Если ФильтрСписокСчетов.Количество() = 0 Тогда
		    СообщитьОбОшибке("Неверно задан список счетов, по которым производится сверка!",,,СтатусСообщения.Важное);
			Возврат;
		КонецЕсли;
	
	КонецЕсли; 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаНачала",    ?(НЕ ЗначениеЗаполнено(ДатаНачала),Неопределено, Новый граница (ДатаНачала,ВидГраницы.Включая)));
	Запрос.УстановитьПараметр("ДатаОкончания", ?(НЕ ЗначениеЗаполнено(ДатаОкончания),неопределено,новый граница(КонецДня(ДатаОкончания), ВидГраницы.Включая)));
	Запрос.УстановитьПараметр("Организация",   Организация);
	Запрос.УстановитьПараметр("Контрагент",    Контрагент);
	Запрос.УстановитьПараметр("Валюта",        ?(НЕ ЗначениеЗаполнено(ВалютаДокумента) или (ВалютаДокумента = мВалютаРегламентированногоУчета), неопределено,ВалютаДокумента));
	Запрос.УстановитьПараметр("ФильтрСписокСчетов", ФильтрСписокСчетов);
	
	АналитикаРасчетов = новый Массив();
	АналитикаРасчетов.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты);
	АналитикаРасчетов.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Договоры);
	Запрос.УстановитьПараметр("АналитикаРасчетов",    АналитикаРасчетов);
	
	Запрос.УстановитьПараметр("ДоговорКонтрагента", ?(НЕ ЗначениеЗаполнено(ДоговорКонтрагента),Неопределено,ДоговорКонтрагента));
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ХозрасчетныйОбороты.Период КАК Дата,
	|	ХозрасчетныйОбороты.Регистратор.Номер КАК Номер,
	|	ХозрасчетныйОбороты.Регистратор КАК Документ,
	|	ХозрасчетныйОбороты.Субконто2 КАК Договор,
	|	ВЫБОР
	|		КОГДА &Валюта = НЕОПРЕДЕЛЕНО
	|			ТОГДА ХозрасчетныйОбороты.СуммаОборотДт
	|		ИНАЧЕ ХозрасчетныйОбороты.ВалютнаяСуммаОборотДт
	|	КОНЕЦ КАК Дебет,
	|	ВЫБОР
	|		КОГДА &Валюта = НЕОПРЕДЕЛЕНО
	|			ТОГДА ХозрасчетныйОбороты.СуммаОборотКт
	|		ИНАЧЕ ХозрасчетныйОбороты.ВалютнаяСуммаОборотКт
	|	КОНЕЦ КАК Кредит,
	|	ХозрасчетныйОбороты.КорСчет,
	|	ХозрасчетныйОбороты.КорСубконто1,
	|	ХозрасчетныйОбороты.КорСубконто2,
	|	ХозрасчетныйОбороты.КорСубконто3,
	|	ХозрасчетныйОбороты.Валюта,
	|	ХозрасчетныйОбороты.ВалютнаяСуммаОборот,
	|	ВЫБОР
	|		КОГДА ХозрасчетныйОбороты.КорСубконто1 ССЫЛКА Справочник.ПрочиеДоходыИРасходы
	|			ТОГДА ХозрасчетныйОбороты.КорСубконто1.ВидПрочихДоходовИРасходов
	|		ИНАЧЕ НЕОПРЕДЕЛЕНО
	|	КОНЕЦ КАК ВидПрочихДоходовИРасходов,
	|	ХозрасчетныйОбороты.Счет
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Обороты(
	|		&ДатаНачала,
	|		&ДатаОкончания,
	|		Регистратор,
	|		Счет В ИЕРАРХИИ (&ФильтрСписокСчетов),
	|		&АналитикаРасчетов,
	|		Организация = &Организация
	|		    И ВЫБОР
	|		        КОГДА &Валюта = НЕОПРЕДЕЛЕНО
	|		            ТОГДА ИСТИНА
	|		        ИНАЧЕ Валюта = &Валюта
	|		    КОНЕЦ
	|		    И Субконто1 = &Контрагент
	|		    И ВЫБОР
	|		        КОГДА &ДоговорКонтрагента = НЕОПРЕДЕЛЕНО
	|		            ТОГДА ИСТИНА
	|		        ИНАЧЕ Субконто2 В ИЕРАРХИИ (&ДоговорКонтрагента)
	|		    КОНЕЦ,
	|		,
	|		) КАК ХозрасчетныйОбороты
	|ГДЕ
	|	ВЫБОР
	|			КОГДА ХозрасчетныйОбороты.КорСчет В ИЕРАРХИИ (&ФильтрСписокСчетов)
	|				ТОГДА ВЫБОР
	|						КОГДА &ДоговорКонтрагента = НЕОПРЕДЕЛЕНО
	|							ТОГДА (НЕ ХозрасчетныйОбороты.КорСубконто1 = &Контрагент)
	|						ИНАЧЕ (НЕ(ХозрасчетныйОбороты.КорСубконто1 = &Контрагент
	|									И ХозрасчетныйОбороты.КорСубконто2 = ХозрасчетныйОбороты.Субконто2))
	|					КОНЕЦ
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И (НЕ (ВЫБОР
	|					КОГДА &Валюта = НЕОПРЕДЕЛЕНО
	|						ТОГДА ХозрасчетныйОбороты.СуммаОборотДт
	|					ИНАЧЕ ХозрасчетныйОбороты.ВалютнаяСуммаОборотДт
	|				КОНЕЦ = 0
	|			И ВЫБОР
	|				КОГДА &Валюта = НЕОПРЕДЕЛЕНО
	|					ТОГДА ХозрасчетныйОбороты.СуммаОборотКт
	|				ИНАЧЕ ХозрасчетныйОбороты.ВалютнаяСуммаОборотКт
	|			КОНЕЦ = 0))
	|
	|УПОРЯДОЧИТЬ ПО
	|	Дата,
	|	Документ";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	НаборДвижений = ПоДаннымОрганизации.Выгрузить();
	НаборДвижений.Колонки.Добавить("Валюта", Новый описаниеТипов("СправочникСсылка.Валюты"));
	НаборДвижений.Колонки.Добавить("ВалютнаяСумма", ПолучитьОписаниеТиповЧисла(15,2));
	
	Пока Выборка.Следующий() Цикл

		Если Выборка.Дебет = 0 И Выборка.Кредит = 0 Тогда
			Продолжить;
		КонецЕсли;

		МетаданныеДокумента = ПолучитьМетаданныеДокумента(Выборка.Документ);
		
		НоваяСтрока = НаборДвижений.Добавить();
		НоваяСтрока.Документ           = Выборка.Документ;
		НоваяСтрока.Договор            = Выборка.Договор;
		НоваяСтрока.Дата               = Выборка.Дата;
		НоваяСтрока.Дебет              = Выборка.Дебет;
		НоваяСтрока.Кредит             = Выборка.Кредит;
		НоваяСтрока.Валюта             = Выборка.Валюта;
		НоваяСтрока.ВалютнаяСумма      = Выборка.ВалютнаяСуммаОборот;

		ВходящийДокумент=ПолучитьВходящийДокумент(Выборка.Документ);
		
		Если ВыводитьПолныеНазванияДокументов Тогда
			Если ВходящийДокумент = "" тогда
				НоваяСтрока.Представление = МетаданныеДокумента.Представление()+" №"+Символы.НПП +Выборка.Номер;
			Иначе
				НоваяСтрока.Представление = МетаданныеДокумента.Представление() +" ("+ВходящийДокумент+")";
			КонецЕсли;	
		Иначе
			
			// Сформируем строку представления
			Представление = "";
			
			//Если Выборка.КорСчет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.ПрочиеДоходыИРасходы) Тогда
			//	
			//	Если НЕ ЗначениеЗаполнено(Выборка.ВидпрочихДоходовИРасходов) Тогда
			//		
			//	ИначеЕсли Выборка.ВидПрочихДоходовИРасходов = Перечисления.ВидыПрочихДоходовИРасходов.КурсовыеРазницы Тогда
			//		Представление = "Курсовые разницы";
			//	ИначеЕсли Выборка.ВидПрочихДоходовИРасходов = Перечисления.ВидыПрочихДоходовИРасходов.ШтрафыПениНеустойкиКПолучениюУплате Тогда
			//		Представление = "Санкции";
			//	ИначеЕсли Выборка.КорСубконто1 = Справочники.ПрочиеДоходыИРасходы.СуммовыеРазницы Тогда
			//		Представление = "Суммовые разницы";
			//	Иначе
			//		Представление = Строка(Выборка.КорСубконто1);
			//	КонецЕсли;
			//	
			//КонецЕсли;
			
			Если не ПустаяСтрока(Представление) Тогда
				// Строка уже отработана
				
			ИначеЕсли Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6800) 
				или Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А7800) Тогда
				Если Выборка.Дебет > 0 Тогда
					Представление = "Возврат займа";
				ИначеЕсли Выборка.Кредит > 0 Тогда
					Представление = "Займ";
				Иначе
					Представление = "Операции по займам";
				КонецЕсли;
			ИначеЕсли  Выборка.Счет = ПланыСчетов.Хозрасчетный.А4860
				или Выборка.Счет = ПланыСчетов.Хозрасчетный.А6960
				тогда
				Представление = "Претензия";
				
			ИначеЕсли Выборка.КорСчет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А5000) 
				или Выборка.КорСчет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А5100) 
				или Выборка.КорСчет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А5200) 
				или Выборка.КорСчет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А5500) 
				тогда
				
				Если (Выборка.Кредит >0) Тогда
					
					Если Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А4300) 
						или Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6000) Тогда
						Представление = "Возврат средств";
						
					ИначеЕсли Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А4000)
						или  Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6300) Тогда
						Представление = "Оплата";
						
					Иначе
						Представление = "Перевод средств";
					КонецЕсли;
					
				ИначеЕсли (Выборка.Дебет >0) Тогда
					Если Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А4300) 
						или Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6000) 
						или Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А4800) 
						или Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6900) 
						Тогда
						
						Представление = "Оплата";
						
					ИначеЕсли Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А4000)
						или  Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6300) Тогда
						Представление = "Возврат средств";
						
					Иначе
						Представление = "Перевод средств";
					КонецЕсли;
				КонецЕсли;
			ИначеЕсли Выборка.КорСчет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А9000) И (Выборка.Дебет > 0) Тогда
				Представление = "Продажа";
			ИначеЕсли Выборка.КорСчет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А9300) 
				И НЕ Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А4300) И НЕ Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6000) 
				И (Выборка.Дебет > 0) Тогда
				Представление = "Продажа";
			ИначеЕсли (Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А4300) 
				ИЛИ Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6000)
				ИЛИ Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6900)
				ИЛИ Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А4800))
				И (Выборка.Кредит <> 0) Тогда
				Представление = "Приход";
			ИначеЕсли Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А4000) или Выборка.Счет.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А6300) Тогда
				//Если ТипЗнч(Выборка.Документ) = Тип("ДокументСсылка.РеализацияТоваровУслуг") И Выборка.Дебет <> 0 Тогда
				Если Выборка.Дебет <> 0 Тогда
					Представление = "Продажа";
				ИначеЕсли (Выборка.Кредит <> 0) Тогда
					Представление = "Оплата";
				КонецЕсли;
			КонецЕсли;
			
			Если ПустаяСтрока(Представление)Тогда
				Если Выборка.Дебет > 0 тогда
					Представление = "Принято";
				ИначеЕсли Выборка.Дебет < 0 тогда
					Представление = "Сторно: принято";
				ИначеЕсли Выборка.Кредит > 0 тогда
					Представление = "Передано";
				Иначе
					Представление = "Сторно: передано";
				КонецЕсли;
			КонецЕсли;
			
			Если ВходящийДокумент = "" тогда
				Если Представление = "Продажа" И ТипЗнч(Выборка.Документ) <> Тип("ДокументСсылка.ОперацияБух") Тогда
					Представление = Представление + " (" + ПолучитьНомерНаПечать(Выборка.Документ) + " от " + Формат(Выборка.Дата, "ДФ=dd.MM.yyyy") + ")";
				Иначе
					Представление = Представление + " ("+Формат(Выборка.Дата, "ДФ=dd.MM.yyyy") + ")";
				КонецЕсли;
			Иначе
				Представление = Представление +" ("+ВходящийДокумент+")";
			КонецЕсли;					  
			
			НоваяСтрока.Представление = Представление;
		КонецЕсли;
		
	КонецЦикла;
	
	
	
	Запрос.УстановитьПараметр("ДатаНачала", ?(НЕ ЗначениеЗаполнено(ДатаНачала),Неопределено, Новый граница (ДатаНачала,ВидГраницы.Исключая)));
	Запрос.Текст = ?(НЕ ЗначениеЗаполнено(ДатаНачала), 
	"ВЫБРАТЬ
	|	0 КАК ОстатокНаНачало, 
	|	0 КАК ОстатокНаКонец", 
	
	"ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА &Валюта = НЕОПРЕДЕЛЕНО
	|			ТОГДА ХозрасчетныйОстаткиНаНачало.СуммаОстаток
	|		ИНАЧЕ ХозрасчетныйОстаткиНаНачало.ВалютнаяСуммаОстаток
	|	КОНЕЦ КАК ОстатокНаНачало, 
	|	0 КАК ОстатокНаКонец
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Остатки(
	|		&ДатаНачала,
	|		Счет В ИЕРАРХИИ (&ФильтрСписокСчетов),
	|		&АналитикаРасчетов,
	|		Организация = &Организация
	|		    И ВЫБОР
	|		        КОГДА &Валюта = НЕОПРЕДЕЛЕНО
	|		            ТОГДА ИСТИНА
	|		        ИНАЧЕ Валюта = &Валюта
	|		    КОНЕЦ
	|		    И Субконто1 = &Контрагент
	|		    И ВЫБОР
	|		        КОГДА &ДоговорКонтрагента = НЕОПРЕДЕЛЕНО
	|		            ТОГДА ИСТИНА
	|		        ИНАЧЕ Субконто2 В ИЕРАРХИИ (&ДоговорКонтрагента)
	|		    КОНЕЦ) КАК ХозрасчетныйОстаткиНаНачало")
	+ "
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|0,
	|	ВЫБОР
	|		КОГДА &Валюта = НЕОПРЕДЕЛЕНО
	|			ТОГДА ХозрасчетныйОстаткиНаНачало.СуммаОстаток
	|		ИНАЧЕ ХозрасчетныйОстаткиНаНачало.ВалютнаяСуммаОстаток
	|	КОНЕЦ
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Остатки(
	|		&ДатаОкончания,
	|		Счет В ИЕРАРХИИ (&ФильтрСписокСчетов),
	|		&АналитикаРасчетов,
	|		Организация = &Организация
	|		    И ВЫБОР
	|		        КОГДА &Валюта = НЕОПРЕДЕЛЕНО
	|		            ТОГДА ИСТИНА
	|		        ИНАЧЕ Валюта = &Валюта
	|		    КОНЕЦ
	|		    И Субконто1 = &Контрагент
	|		    И ВЫБОР
	|		        КОГДА &ДоговорКонтрагента = НЕОПРЕДЕЛЕНО
	|		            ТОГДА ИСТИНА
	|		        ИНАЧЕ Субконто2  В ИЕРАРХИИ (&ДоговорКонтрагента)
	|		    КОНЕЦ) КАК ХозрасчетныйОстаткиНаНачало 
	|ИТОГИ
	|	СУММА(ОстатокНаНачало),
	|	СУММА(ОстатокНаКонец)
	|ПО ОБЩИЕ";
	
	Выборка = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "ОБЩИЕ");
	Выборка.Следующий();
	ОстатокНаНачало = Выборка.ОстатокНаНачало;
	ОстатокНаКонец  = Выборка.ОстатокНаКонец;
	
	Если ВалютаДокумента = мВалютаРегламентированногоУчета И НЕ ВыводитьПолныеНазванияДокументов  Тогда
		НаборДвижений.Свернуть("Дата,Документ,Представление,Договор,Валюта","Дебет, Кредит, ВалютнаяСумма");
		Для каждого СтрокаДвижений Из НаборДвижений Цикл
			Если СтрокаДвижений.ВалютнаяСумма >0 тогда
				
				СтрокаДвижений.Представление = СтрокаДвижений.Представление+" ("+Формат(СтрокаДвижений.ВалютнаяСумма, "ЧЦ=15; ЧДЦ=2")+" "+строка(СтрокаДвижений.Валюта) +")";
			ИначеЕсли СтрокаДвижений.ВалютнаяСумма <0 тогда
				Множитель = ?(СтрокаДвижений.Дебет + СтрокаДвижений.Кредит>0, -1,1);
				
				СтрокаДвижений.Представление = СтрокаДвижений.Представление+" ("+Формат(Множитель*СтрокаДвижений.ВалютнаяСумма, "ЧЦ=15; ЧДЦ=2")+" "+строка(СтрокаДвижений.Валюта) +")";
	
			КонецЕсли;
		КонецЦикла; 
		
	Иначе
		НаборДвижений.Свернуть("Дата,Документ,Представление,Договор","Дебет, Кредит");	
	КонецЕсли; 
	
	Если ВыводитьПолныеНазванияДокументов Тогда	
		НаборДвижений.Свернуть("Дата,Документ,Представление,Договор","Дебет, Кредит");
	КонецЕсли;
	
	Если РазбитьПоДоговорам Тогда		
		НаборДвижений.Сортировать("Договор, Дата,Документ,Представление");		
	Иначе	
		НаборДвижений.Сортировать("Дата,Документ,Представление,Договор");
	КонецЕсли;
	
	
	ПоДаннымОрганизации.Загрузить(НаборДвижений);


КонецПроцедуры

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("АктСверки", "Акт сверки");

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

// Получение метаданных по документам
// Если метаданные по данному виду документа получались ранее - получаем из соответствия,
// иначе получаем метаданные и дополняем соответствие
// Параметры
//  ДокументСсылка  – <ДокументСсылка> – ссылка на документ
//
// Возвращаемое значение:
//   Структура метаданных
//
Функция ПолучитьМетаданныеДокумента(ДокументСсылка)
	Если МетаданныеПоДокументам[ТипЗнч(ДокументСсылка)] = Неопределено Тогда
		МетаданныеПоДокументам.Вставить(ТипЗнч(ДокументСсылка),ДокументСсылка.Метаданные());
	КонецЕсли; 
	
    Возврат МетаданныеПоДокументам[ТипЗнч(ДокументСсылка)];
	
КонецФункции // ПолучитьМетаданныеДокумента()

Процедура ЗаполнитьПоДаннымОрганизации() Экспорт
	
	ТабЗнач = ПоДаннымОрганизации.Выгрузить();
	ТабЗнач.Колонки.Дебет.Имя  = "КредитК";
	ТабЗнач.Колонки.Кредит.Имя = "Дебет";
	ТабЗнач.Колонки.КредитК.Имя= "Кредит";
	
	Для каждого СтрокаДвижений Из ТабЗнач Цикл
		Представление = СокрЛП(СтрокаДвижений.Представление);
		Если Лев(Представление, 8) = "Передано" Тогда
			Представление = "Принято" + Сред(Представление, 9);
			
		ИначеЕсли Лев(Представление, 7) = "Принято" Тогда
			Представление = "Передано" + Сред(Представление, 8);

		ИначеЕсли Лев(Представление, 7) = "Продажа" Тогда
			Представление = "Приход" + Сред(Представление, 8);

		ИначеЕсли Лев(Представление, 6) = "Приход" Тогда
			Представление = "Продажа" + Сред(Представление, 7);
		КонецЕсли;
		СтрокаДвижений.Представление = Представление;
	КонецЦикла;
	
	ПоДаннымКонтрагента.Загрузить(ТабЗнач);
	
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
МетаданныеПоДокументам = Новый Соответствие();
