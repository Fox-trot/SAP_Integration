﻿// Строки, хранят реквизиты имеющие смысл только для бух. учета и упр. соответственно
// в случае если документ не отражается в каком-то виде учета, делаются невидимыми
Перем мСтрокаРеквизитыБухУчета Экспорт; // (Регл)
Перем мДокументОснование       Экспорт;

Перем мУчетнаяПолитика;                 // (Общ)

Перем мВалютаРегламентированногоУчета Экспорт;

//#Если Клиент Тогда

Функция РасчетОстатка(СтрокаВалюта, СуммаРасхода)
	Если МногоВалютный Тогда  		
		Ост  = 0;
		Для каждого СтрокаКому из Получено Цикл
			Если СтрокаКому.Валюта = СтрокаВалюта Тогда 
				Ост = Ост + СтрокаКому.Сумма;
			Конецесли;	
		КонецЦикла;
		
		Ост = Ост - СуммаРасхода;
		
		Если ТипОстатка = 1 Тогда //остаток
			Ост = Ост + ПредОстаток;
		Иначе //перерасход
			Ост = Ост - ПредОстаток;
		КонецЕсли;
		Возврат Ост;
	Иначе
		Ост  = 0;
		Для каждого СтрокаКому из Получено Цикл
			Если МногоВалютный Тогда
				Если СтрокаКому.Валюта = СтрокаВалюта Тогда 
					Ост = Ост + СтрокаКому.Сумма;
				Конецесли;
			Иначе 
				Ост = Ост + СтрокаКому.Сумма;
			Конецесли;
		КонецЦикла;
		Ост = Ост - Расходы.Итог("Сумма");
		
		Если ТипОстатка = 1 Тогда //остаток
			Ост = Ост + ПредОстаток;
		Иначе //перерасход
			Ост = Ост - ПредОстаток;
		КонецЕсли;
		Возврат Ост;		
	КонецЕсли;
	
КонецФункции  //РасчетОстатка

//Печать авансового отчета
Функция ПечатьАвансовогоОтчета()
	
	ТабДокумент = Новый ТабличныйДокумент;
	Макет = ПолучитьМакет("ПечатьАвансовогоОтчета");
	
	Если НЕ МногоВалютный тогда
		
		Если не Валюта.Пустая() Тогда
			Курс = ПолучитьКурсВалюты(Валюта,Дата).Курс;
			Кратность = ПолучитьКурсВалюты(Валюта,Дата).Кратность;
			Кратность = ?(Кратность = 0, 1, Кратность);
		Иначе
			Курс = 1;
			Кратность = 1;
		КонецЕсли;
		
		// Заголовок
		Область = Макет.ПолучитьОбласть("Заголовок");
		Область.Параметры.НазваниеОрганизации = Организация.Наименование;
		Область.Параметры.Должность = ДолжностьСотрудника(Сотрудник,Дата);
		Область.Параметры.Дата = Формат(Дата,"ДФ=dd.MM.yyyy");
		Область.Параметры.Подразделение = ПодразделениеСотрудника(Сотрудник,Дата);
		Область.Параметры.Сотрудник = Сотрудник.Наименование;
		ТабДокумент.Вывести(Область);
		
		СтрПредОстаток = "" + Формат(ПредОстаток,"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
		Если (не ТипОтчета) и (СтрПредОстаток <> "") Тогда
			СтрПредОстаток = СтрПредОстаток + " " + СокрЛП(Валюта.Наименование);
		КонецЕсли;
		Если ТипОстатка Тогда
			СтрНачальныйОстаток = СтрПредОстаток;
			СтрНачальныйПерерасход = "";
		Иначе
			СтрНачальныйОстаток = "";
			СтрНачальныйПерерасход = СтрПредОстаток;
		КонецЕсли;
		
		СтрСуммы = Новый СписокЗначений;
		
		инд = 0; СтрИтогоПолучено = 0;
		Для каждого СтрокаКому из Получено Цикл
			
			Если МногоВалютный тогда
				ВалютаВОтчете = СтрокаКому.Валюта ;
			Иначе
				ВалютаВОтчете = Валюта ;
			КонецЕсли;
			
			СтрСуммы.Добавить("" + Формат(СтрокаКому.Сумма,"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '"));
			Если (не ТипОтчета) и (СтрСуммы.Получить(инд).Значение <> "") Тогда
				СтрСуммы.Получить(инд).Значение = СтрСуммы.Получить(инд).Значение + " " + СокрЛП(ВалютаВОтчете);
			КонецЕсли;
			инд = инд + 1;
			СтрИтогоПолучено = СтрИтогоПолучено + СтрокаКому.Сумма;
		КонецЦикла;
		
		ВалютаВОтчете = Валюта ;
		
		СтрИтогоПолучено = "" + Формат(СтрИтогоПолучено,"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
		Если не ТипОтчета и (СтрИтогоПолучено <> "") Тогда
			СтрИтогоПолучено = СтрИтогоПолучено + " " + СокрЛП(ВалютаВОтчете);
		КонецЕсли;
		
		Если не ТипОтчета Тогда
			СтрИзрасходовано = "" + Формат(Расходы.Итог("Сумма"),"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
			СтрИзрасходованоПрописью = СформироватьСуммуПрописью(Расходы.Итог("Сумма"),?(ВалютаВОтчете.Пустая(),мВалютаРегламентированногоУчета,ВалютаВОтчете));
		Иначе
			СтрИзрасходовано = "" + Формат(Расходы.Итог("Сумма"),"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
			СтрИзрасходованоПрописью = СформироватьСуммуПрописью(Расходы.Итог("Сумма"),?(ВалютаВОтчете.Пустая(),мВалютаРегламентированногоУчета,ВалютаВОтчете));
		КонецЕсли;
		Если (не ТипОтчета) и (СтрИзрасходовано <> "") Тогда
			СтрИзрасходовано = СтрИзрасходовано + " " + СокрЛП(ВалютаВОтчете);
		КонецЕсли;
		
		ТекОстаток = РасчетОстатка(Неопределено,Неопределено);
		СтрТекОстаток = "" + Формат(?(ТекОстаток>0,ТекОстаток,-ТекОстаток),"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
		Если (не ТипОтчета) и (СтрТекОстаток <> "") Тогда
			СтрТекОстаток = СтрТекОстаток + " " + СокрЛП(ВалютаВОтчете.Наименование);
		КонецЕсли;
		Если ТекОстаток > 0 Тогда
			СтрКонечныйОстаток = СтрТекОстаток;
			СтрКонечныйПерерасход = "";
		Иначе
			СтрКонечныйОстаток = "";
			СтрКонечныйПерерасход = СтрТекОстаток;
		КонецЕсли;
		
		Если не ТипОтчета Тогда
			БухИт = Обработки.БухгалтерскиеИтоги.Создать();
			БухИт.РассчитатьИтоги("Хозрасчетный","НачальныйОстатокДт,НачальныйОстатокКт","Сумма,ВалютнаяСумма","Счет",МоментВремени(),,,"4221",ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Сотрудники,,,"Субконто1,Организация",Сотрудник,Организация);
			Ресурс = ?(ТипОтчета,"Сумма","ВалютнаяСумма");
			РублевыйОстаток = БухИт.ПолучитьИтог("СуммаНачальныйОстатокДт","Счет","4221")-БухИт.ПолучитьИтог("СуммаНачальныйОстатокКт","Счет","4221");
			ВалютныйОстаток = БухИт.ПолучитьИтог("ВалютнаяСуммаНачальныйОстатокДт","Счет","4221")-БухИт.ПолучитьИтог("ВалютнаяСуммаНачальныйОстатокКт","Счет","4221");
			НовыйРублевыйОстаток = Окр(ВалютныйОстаток*Курс/Кратность,2,1);
			КурсоваяРазница = НовыйРублевыйОстаток - РублевыйОстаток;
			
			Если КурсоваяРазница <> 0 Тогда
				Область = Макет.ПолучитьОбласть("ПустаяСтрока");
				Область.Параметры.НомерДок = Номер; Область.Параметры.ДатаДок = Формат(Дата,"ДФ=dd.MM.yyyy");
				ТабДокумент.Вывести(Макет.ПолучитьОбласть("ПустаяСтрока|Таблица"));
				Область = Макет.ПолучитьОбласть("КурсоваяРазница");
				Область.Параметры.СчетКурсовойРазницыДеб  = ?(КурсоваяРазница>0,"42.21","95.40");
				Область.Параметры.СчетКурсовойРазницыКред = ?(КурсоваяРазница<0,"42.21","96.20");
				Область.Параметры.КурсоваяРазница = ?(КурсоваяРазница>0,КурсоваяРазница,-КурсоваяРазница);
				ТабДокумент.Присоединить(Макет.ПолучитьОбласть("КурсоваяРазница|Таблица"));
			КонецЕсли;
		КонецЕсли;
		
		// Секция_1
		Область = Макет.ПолучитьОбласть("Секция_1|ДоТаблицы");
		Область.Параметры.НомерДок = Номер;
		Область.Параметры.ДатаДок = Формат(Дата,"ДФ=dd.MM.yyyy");
		ТабДокумент.Вывести(Область);
		
		// Израсходовано
		Область = Макет.ПолучитьОбласть("Израсходовано|Таблица");
		Область.Параметры.Счет69=?(ТипОтчета,"69.70","69.71");
		Область.Параметры.Израсходовано = Расходы.Итог("Сумма")*Курс/Кратность;
		ТабДокумент.Присоединить(Область);
		
		Если не ТипОтчета Тогда
			ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_3|ДоТаблицы"));
			Область = Макет.ПолучитьОбласть("ВалИзрасходовано|Таблица");
			Область.Параметры.ВалИзрасходовано = Формат(Расходы.Итог("Сумма"),"ЧЦ=15; ЧДЦ=2; ЧРД=-") + " " + СокрЛП(ВалютаВОтчете.Наименование);
			ТабДокумент.Присоединить(Область);
		КонецЕсли;
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	АвансовыйОтчетРасходы.СчетЗатрат КАК СчетЗатрат,
		|	СУММА(АвансовыйОтчетРасходы.Сумма) КАК Сумма,
		|	СУММА(АвансовыйОтчетРасходы.СуммаНДС) КАК СуммаНДС
		|ИЗ
		|	Документ.АвансовыйОтчет.Расходы КАК АвансовыйОтчетРасходы
		|ГДЕ
		|	АвансовыйОтчетРасходы.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	АвансовыйОтчетРасходы.СчетЗатрат
		|ИТОГИ ПО
		|	СчетЗатрат";
		
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		Результат = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Если Результат = неопределено Тогда
			Возврат ТабДокумент;
		КонецЕсли;
		
		Пока Результат.Следующий() Цикл
			//Если Результат.СчетЗатрат.ЭтоГруппа() Тогда
			//	Продолжить;
			//КонецЕсли;
			Область = Макет.ПолучитьОбласть("Секция_2|ДоТаблицы");
			Область.Параметры.Заполнить(ЭтотОбъект);
			ТабДокумент.Вывести(Область);
			Если ТипОтчета Тогда
				ПоСчетуБезНДС = Результат.Сумма - Результат.СуммаНДС;
			Иначе
				ПоСчетуБезНДС = Окр(Результат.Сумма*Курс/Кратность,2,1) - Окр(Результат.СуммаНДС*Курс/Кратность,2,1);
			КонецЕсли;
			Область = Макет.ПолучитьОбласть("НеПустаяСтрока|Таблица");
			Область.Параметры.КоррСчет = Результат.СчетЗатрат;
			Область.Параметры.ПоСчетуБезНДС = ПоСчетуБезНДС;
			ТабДокумент.Присоединить(Область);
		КонецЦикла;
		
		Если Расходы.Итог("СуммаНДС") > 0 Тогда
			ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_3|ДоТаблицы"));
			Область = Макет.ПолучитьОбласть("НДС|Таблица");
			Если ТипОтчета Тогда
				Область.Параметры.ИтогоНДС = Расходы.Итог("СуммаНДС");
			Иначе
				Область.Параметры.ИтогоНДС = Окр(Расходы.Итог("СуммаНДС")*Курс/Кратность,2,1);
			КонецЕсли;
			ТабДокумент.Присоединить(Область);
		КонецЕсли;
		
		ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_4|ДоТаблицы"));
		ТабДокумент.Присоединить(Макет.ПолучитьОбласть("ПустаяСтрока|Таблица"));
		ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_5|ДоТаблицы"));
		ТабДокумент.Присоединить(Макет.ПолучитьОбласть("ПустаяСтрока|Таблица"));
		Область = Макет.ПолучитьОбласть("Секция_6");
		Область.Параметры.СтрНачальныйОстаток = СтрНачальныйОстаток;
		ТабДокумент.Вывести(Область);
		Область = Макет.ПолучитьОбласть("Секция_7");
		Область.Параметры.СтрНачальныйПерерасход = СтрНачальныйПерерасход;
		Область.Параметры.Дата = Формат(Дата,"ДЛФ=DD");
		ТабДокумент.Вывести(Область);
		ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_8"));
		инд=1;
		ДляОбласти=8;
		Для каждого СтрокаПолучено из Получено Цикл
			Если инд>=3 Тогда 
				Окончание="Н";
				ДляОбласти="Н";
			Иначе
				Окончание=инд;
				ДляОбласти=инд+8;
			КонецЕсли;
			Область = Макет.ПолучитьОбласть("Секция_"+ДляОбласти);
			Область.Параметры.Заполнить(СтрокаПолучено);
			Область.Параметры["СтрСумма"+Окончание] = СтрСуммы.Получить(инд-1).Значение;
			Область.Параметры.инд = инд;
			ТабДокумент.Вывести(Область);
			инд=инд+1;
		КонецЦикла;
		
		Для итер=1 по 4-инд цикл
			Область = Макет.ПолучитьОбласть("Секция_"+(ДляОбласти+Итер));
			Область.Параметры.инд = инд+итер-1;
			ТабДокумент.Вывести(Область);
		КонецЦикла;
		
		Область = Макет.ПолучитьОбласть("Секция_12");
		Область.Параметры.СтрИтогоПолучено=СтрИтогоПолучено;
		Область.Параметры.СтрИзрасходовано=СтрИзрасходовано;
		ТабДокумент.Вывести(Область);
		
		Область = Макет.ПолучитьОбласть("ПослеТаблицы");
		Область.Параметры.СтрИзрасходовано = СтрИзрасходовано;
		Область.Параметры.ПредставлениеГода = Лев(Число(Год(Дата)),4);
		Область.Параметры.СтрКонечныйОстаток = СтрКонечныйОстаток;
		Область.Параметры.СтрИзрасходованоПрописью = СтрИзрасходованоПрописью;
		Область.Параметры.СтрКонечныйПерерасход = СтрКонечныйПерерасход;
		Область.Параметры.ПриложеноДок = ПриложеноДок;
		Область.Параметры.КонечныйОстатокПерерасход = СтрКонечныйОстаток + СтрКонечныйПерерасход;
		ТабДокумент.Вывести(Область);
		
		//ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		
		ТабДокумент.Вывести(Макет.ПолучитьОбласть("Шапка"));
		
		Область = Макет.ПолучитьОбласть("Строка");
		Для каждого СтрокаРасх из Расходы Цикл
			Если Валюта.Пустая() Тогда
				СуммаСтроки = Формат(СтрокаРасх.Сумма,"ЧЦ=15; ЧДЦ=2; ЧРД=-");
			Иначе
				СуммаСтроки = Формат(СтрокаРасх.Сумма*Курс/Кратность,"ЧЦ=15; ЧДЦ=2; ЧРД=-")+"
				|"+Формат(СтрокаРасх.Сумма,"ЧЦ=15; ЧДЦ=2; ЧРД=-")+" "+СокрЛП(Валюта.Наименование);
			КонецЕсли;
			Область.Параметры.Заполнить(СтрокаРасх);
			Область.Параметры.Дата = ?(СтрокаРасх.ДатаПо=ПустоеЗначениеТипа(Тип("Дата")),Формат(СтрокаРасх.ДатаС, "ДФ=dd.MM.yy"),"С "+Формат(СтрокаРасх.ДатаС, "ДФ=dd.MM.yy")+ Символы.ПС+"по "+Формат(СтрокаРасх.ДатаПо, "ДФ=dd.MM.yy"));
			Область.Параметры.СуммаСтроки = СуммаСтроки;
			ТабДокумент.Вывести(Область);
		КонецЦикла;
		Область = Макет.ПолучитьОбласть("Подвал"); 
		Если Валюта.Пустая() Тогда
			Область.Параметры.СуммаВсего = Формат(Расходы.Итог("Сумма"),"ЧЦ=15; ЧДЦ=2; ЧРД=-");
		Иначе
			Область.Параметры.СуммаВсего = Формат(Расходы.Итог("Сумма")*Курс/Кратность,"ЧЦ=15; ЧДЦ=2; ЧРД=-")+"
			|"+Формат(Расходы.Итог("Сумма"),"ЧЦ=15; ЧДЦ=2; ЧРД=-")+" "+СокрЛП(Валюта.Наименование);
		КонецЕсли;
		ТабДокумент.Вывести(Область);
		
		Возврат ТабДокумент;
		
	Иначе // МультиВалютный вариант
		
	запрос = Новый Запрос ;
	запрос.Текст = "ВЫБРАТЬ
	|	АвансовыйОтчетПолучено.Ссылка,
	|	АвансовыйОтчетПолучено.Кому,
	|	АвансовыйОтчетПолучено.Дата,
	|	АвансовыйОтчетПолучено.Сумма КАК Сумма,
	|	АвансовыйОтчетПолучено.Валюта,
	|	АвансовыйОтчетПолучено.НомерСтроки
	|ПОМЕСТИТЬ ВТ_Получено
	|ИЗ
	|	Документ.АвансовыйОтчет.Получено КАК АвансовыйОтчетПолучено
	|ГДЕ
	|	АвансовыйОтчетПолучено.Ссылка = &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	АвансовыйОтчетРасходы.Ссылка,
	|	АвансовыйОтчетРасходы.Сумма КАК Сумма,
	|	АвансовыйОтчетРасходы.Валюта,
	|	АвансовыйОтчетРасходы.НомерСтроки
	|ПОМЕСТИТЬ ВТ_Расходы
	|ИЗ
	|	Документ.АвансовыйОтчет.Расходы КАК АвансовыйОтчетРасходы
	|ГДЕ
	|	АвансовыйОтчетРасходы.Ссылка = &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(ВТ_Расходы.Валюта, ЗНАЧЕНИЕ(Справочник.Валюты.ПустаяСсылка)) КАК ВалютаРасхода,
	|	ВТ_Расходы.Ссылка.СчетУчетаСотрудника КАК ШапкаСчетУчетаСотрудника,
	|	ВТ_Расходы.Ссылка.СчетЗатрат КАК ШапкаСчетЗатрат,
	|	ВТ_Расходы.Ссылка.НаименованиеАванса КАК ШапкаНаименованиеАванса,
	|	ВТ_Расходы.Ссылка.ПриложеноДок КАК ШапкаПриложеноДок,
	|	ВТ_Расходы.Сумма КАК СуммаРасхода,
	|	ЕСТЬNULL(ВТ_Получено.Валюта, ЗНАЧЕНИЕ(Справочник.Валюты.ПустаяСсылка)) КАК ВалютаПолучено,
	|	ВТ_Получено.Сумма КАК СуммаПолучено,
	|	ВТ_Получено.Дата,
	|	ВТ_Получено.Кому,
	|	ВТ_Расходы.НомерСтроки КАК НомерСтроки
	|ИЗ
	|	ВТ_Расходы КАК ВТ_Расходы
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Получено КАК ВТ_Получено
	|		ПО ВТ_Расходы.Ссылка = ВТ_Получено.Ссылка
	|			И ВТ_Расходы.Валюта = ВТ_Получено.Валюта
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки
	|ИТОГИ
	|	СУММА(СуммаРасхода),
	|	СУММА(СуммаПолучено)
	|ПО
	|	ВалютаРасхода";
	
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	Рез_ = Запрос.Выполнить();
	РезРасходы = Рез_.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	//Рез_.Выгрузить().ВыбратьСтроку();
	
	ДопКНомеру = 1 ;
	Пока РезРасходы.Следующий()Цикл
		
		СтрокаВалюта = РезРасходы.ВалютаРасхода ;
		//Если не Валюта.Пустая() Тогда
		Попытка
			Курс = ПолучитьКурсВалюты(СтрокаВалюта,Дата).Курс;
			Кратность = ПолучитьКурсВалюты(СтрокаВалюта,Дата).Кратность;
			Кратность = ?(Кратность = 0, 1, Кратность);
		Исключение
			Курс = 1;
			Кратность = 1;
			Сообщить("нет данных о курсе валюты!"); 
		КонецПопытки;
		
		// Заголовок
		Область = Макет.ПолучитьОбласть("Заголовок");
		Область.Параметры.НазваниеОрганизации = Организация.Наименование;
		Область.Параметры.Должность = ДолжностьСотрудника(Сотрудник,Дата);
		Область.Параметры.Дата = Формат(Дата,"ДФ=dd.MM.yyyy");
		Область.Параметры.Подразделение = ПодразделениеСотрудника(Сотрудник,Дата);
		Область.Параметры.Сотрудник = Сотрудник.Наименование;
		ТабДокумент.Вывести(Область);
		
		СтрПредОстаток = "" + Формат(ПредОстаток,"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
		Если (не ТипОтчета) и (СтрПредОстаток <> "") Тогда
			СтрПредОстаток = СтрПредОстаток + " " + СокрЛП(Валюта.Наименование);
		КонецЕсли;
		Если ТипОстатка Тогда
			СтрНачальныйОстаток = СтрПредОстаток;
			СтрНачальныйПерерасход = "";
		Иначе
			СтрНачальныйОстаток = "";
			СтрНачальныйПерерасход = СтрПредОстаток;
		КонецЕсли;
		
		СтрСуммы = Новый СписокЗначений;
		
		инд = 0; СтрИтогоПолучено = 0;
		
		СтрокаКому = РезРасходы.Выбрать ();  // детали по валюте получено
		
		//Пока СтрокаКому.Следующий() Цикл
		Для каждого  СтрокаКому из Получено Цикл
			Если  СтрокаКому.Валюта = СтрокаВалюта Тогда
				
				Если МногоВалютный тогда
					ВалютаВОтчете = СтрокаКому.Валюта ;
				Иначе
					ВалютаВОтчете = Валюта ;
				КонецЕсли;
				
				СтрСуммы.Добавить("" + Формат(СтрокаКому.Сумма,"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '"));
				Если (не ТипОтчета) и (СтрСуммы.Получить(инд).Значение <> "") Тогда
					СтрСуммы.Получить(инд).Значение = СтрСуммы.Получить(инд).Значение + " " + СокрЛП(ВалютаВОтчете);
				КонецЕсли;
				инд = инд + 1;
				СтрИтогоПолучено = СтрИтогоПолучено + СтрокаКому.Сумма; 			
			КонецЕсли; 						
		КонецЦикла;
		
		СтрИтогоПолучено = "" + Формат(СтрИтогоПолучено,"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
		Если не ТипОтчета и (СтрИтогоПолучено <> "") Тогда
			СтрИтогоПолучено = СтрИтогоПолучено + " " + СокрЛП(ВалютаВОтчете);
		КонецЕсли;
		
		Если не ТипОтчета Тогда
			СтрИзрасходовано = "" + Формат(РезРасходы.СуммаРасхода,"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
			СтрИзрасходованоПрописью = СформироватьСуммуПрописью(РезРасходы.СуммаРасхода,?(ВалютаВОтчете.Пустая(),мВалютаРегламентированногоУчета,ВалютаВОтчете));
		Иначе
			СтрИзрасходовано = "" + Формат(РезРасходы.СуммаРасхода,"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
			СтрИзрасходованоПрописью = СформироватьСуммуПрописью(РезРасходы.СуммаРасхода,?(ВалютаВОтчете.Пустая(),мВалютаРегламентированногоУчета,ВалютаВОтчете));
		КонецЕсли;
		Если (не ТипОтчета) и (СтрИзрасходовано <> "") Тогда
			СтрИзрасходовано = СтрИзрасходовано + " " + СокрЛП(ВалютаВОтчете);
		КонецЕсли;
		
		ТекОстаток = РасчетОстатка(СтрокаВалюта,РезРасходы.СуммаРасхода );
		СтрТекОстаток = "" + Формат(?(ТекОстаток>0,ТекОстаток,-ТекОстаток),"ЧЦ=15; ЧДЦ=2; ЧРД=-; ЧРГ=' '");
		Если (не ТипОтчета) и (СтрТекОстаток <> "") Тогда
			СтрТекОстаток = СтрТекОстаток + " " + СокрЛП(ВалютаВОтчете.Наименование);
		КонецЕсли;
		Если ТекОстаток > 0 Тогда
			СтрКонечныйОстаток = СтрТекОстаток;
			СтрКонечныйПерерасход = "";
		Иначе
			СтрКонечныйОстаток = "";
			СтрКонечныйПерерасход = СтрТекОстаток;
		КонецЕсли;
		
		Если не ТипОтчета Тогда
			БухИт = Обработки.БухгалтерскиеИтоги.Создать();
			БухИт.РассчитатьИтоги("Хозрасчетный","НачальныйОстатокДт,НачальныйОстатокКт","Сумма,ВалютнаяСумма","Счет",МоментВремени(),,,"4221",ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Сотрудники,,,"Субконто1,Организация",Сотрудник,Организация);
			Ресурс = ?(ТипОтчета,"Сумма","ВалютнаяСумма");
			РублевыйОстаток = БухИт.ПолучитьИтог("СуммаНачальныйОстатокДт","Счет","4221")-БухИт.ПолучитьИтог("СуммаНачальныйОстатокКт","Счет","4221");
			ВалютныйОстаток = БухИт.ПолучитьИтог("ВалютнаяСуммаНачальныйОстатокДт","Счет","4221")-БухИт.ПолучитьИтог("ВалютнаяСуммаНачальныйОстатокКт","Счет","4221");
			НовыйРублевыйОстаток = Окр(ВалютныйОстаток*Курс/Кратность,2,1);
			КурсоваяРазница = НовыйРублевыйОстаток - РублевыйОстаток;
			
			Если КурсоваяРазница <> 0 Тогда
				Область = Макет.ПолучитьОбласть("ПустаяСтрока");
				Область.Параметры.НомерДок = Номер; Область.Параметры.ДатаДок = Формат(Дата,"ДФ=dd.MM.yyyy");
				ТабДокумент.Вывести(Макет.ПолучитьОбласть("ПустаяСтрока|Таблица"));
				Область = Макет.ПолучитьОбласть("КурсоваяРазница");
				Область.Параметры.СчетКурсовойРазницыДеб  = ?(КурсоваяРазница>0,"42.21","95.40");
				Область.Параметры.СчетКурсовойРазницыКред = ?(КурсоваяРазница<0,"42.21","96.20");
				Область.Параметры.КурсоваяРазница = ?(КурсоваяРазница>0,КурсоваяРазница,-КурсоваяРазница);
				ТабДокумент.Присоединить(Макет.ПолучитьОбласть("КурсоваяРазница|Таблица"));
			КонецЕсли;
		КонецЕсли;
		
		// Секция_1
		Область = Макет.ПолучитьОбласть("Секция_1|ДоТаблицы");
		Область.Параметры.НомерДок = Номер + "_"+ ДопКНомеру;
		Область.Параметры.ДатаДок = Формат(Дата,"ДФ=dd.MM.yyyy");
		ТабДокумент.Вывести(Область);
		
		// Израсходовано
		Область = Макет.ПолучитьОбласть("Израсходовано|Таблица");
		Область.Параметры.Счет69=?(ТипОтчета,"69.70","69.71");
		Область.Параметры.Израсходовано = РезРасходы.СуммаРасхода*Курс/Кратность;
		ТабДокумент.Присоединить(Область);
		
		Если не ТипОтчета Тогда
			ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_3|ДоТаблицы"));
			Область = Макет.ПолучитьОбласть("ВалИзрасходовано|Таблица");
			Область.Параметры.ВалИзрасходовано = Формат(РезРасходы.СуммаРасхода,"ЧЦ=15; ЧДЦ=2; ЧРД=-") + " " + СокрЛП(ВалютаВОтчете.Наименование);
			ТабДокумент.Присоединить(Область);
		КонецЕсли;
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	АвансовыйОтчетРасходы.СчетЗатрат КАК СчетЗатрат,
		|	СУММА(АвансовыйОтчетРасходы.Сумма) КАК Сумма,
		|	СУММА(АвансовыйОтчетРасходы.СуммаНДС) КАК СуммаНДС,
		|	АвансовыйОтчетРасходы.Валюта
		|ИЗ
		|	Документ.АвансовыйОтчет.Расходы КАК АвансовыйОтчетРасходы
		|ГДЕ
		|	АвансовыйОтчетРасходы.Ссылка = &Ссылка
		|	И АвансовыйОтчетРасходы.Валюта = &СтрокаВалюта
		|
		|СГРУППИРОВАТЬ ПО
		|	АвансовыйОтчетРасходы.СчетЗатрат,
		|	АвансовыйОтчетРасходы.Валюта
		|ИТОГИ ПО
		|	СчетЗатрат";
		
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.УстановитьПараметр("СтрокаВалюта", СтрокаВалюта);

		Результат_ = Запрос.Выполнить();
		Результат = Результат_.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		//Результат_.Выгрузить().ВыбратьСтроку();
		
		Если Результат = неопределено Тогда
			Возврат ТабДокумент;
		КонецЕсли;
		
		Пока Результат.Следующий() Цикл
			//Если Результат.СчетЗатрат.ЭтоГруппа() Тогда
			//	Продолжить;
			//КонецЕсли;
			Область = Макет.ПолучитьОбласть("Секция_2|ДоТаблицы");
			Область.Параметры.Заполнить(ЭтотОбъект);
			ТабДокумент.Вывести(Область);
			Если ТипОтчета Тогда
				ПоСчетуБезНДС = Результат.Сумма - Результат.СуммаНДС;
			Иначе
				ПоСчетуБезНДС = Окр(Результат.Сумма*Курс/Кратность,2,1) - Окр(Результат.СуммаНДС*Курс/Кратность,2,1);
			КонецЕсли;
			Область = Макет.ПолучитьОбласть("НеПустаяСтрока|Таблица");
			Область.Параметры.КоррСчет = Результат.СчетЗатрат;
			Область.Параметры.ПоСчетуБезНДС = ПоСчетуБезНДС;
			ТабДокумент.Присоединить(Область);
		КонецЦикла;
		
		Если Расходы.Итог("СуммаНДС") > 0 Тогда
			ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_3|ДоТаблицы"));
			Область = Макет.ПолучитьОбласть("НДС|Таблица");
			Если ТипОтчета Тогда
				Область.Параметры.ИтогоНДС = Расходы.Итог("СуммаНДС");
			Иначе
				Область.Параметры.ИтогоНДС = Окр(Расходы.Итог("СуммаНДС")*Курс/Кратность,2,1);
			КонецЕсли;
			ТабДокумент.Присоединить(Область);
		КонецЕсли;
		
		ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_4|ДоТаблицы"));
		ТабДокумент.Присоединить(Макет.ПолучитьОбласть("ПустаяСтрока|Таблица"));
		ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_5|ДоТаблицы"));
		ТабДокумент.Присоединить(Макет.ПолучитьОбласть("ПустаяСтрока|Таблица"));
		Область = Макет.ПолучитьОбласть("Секция_6");
		Область.Параметры.СтрНачальныйОстаток = СтрНачальныйОстаток;
		ТабДокумент.Вывести(Область);
		Область = Макет.ПолучитьОбласть("Секция_7");
		Область.Параметры.СтрНачальныйПерерасход = СтрНачальныйПерерасход;
		Область.Параметры.Дата = Формат(Дата,"ДЛФ=DD");
		ТабДокумент.Вывести(Область);
		ТабДокумент.Вывести(Макет.ПолучитьОбласть("Секция_8"));
		инд=1;
		
		//РезРасходы.Сбросить();
		//СтрокаПолучено = РезРасходы.Выбрать(); 
		Для каждого СтрокаПолучено из Получено Цикл
		//Пока  СтрокаПолучено.Следующий () Цикл
			Если СтрокаПолучено.Валюта = СтрокаВалюта Тогда
				Если инд>=3 Тогда 
					Окончание="Н";
					ДляОбласти="Н";
				Иначе
					Окончание=инд;
					ДляОбласти=инд+8;
				КонецЕсли;
				Область = Макет.ПолучитьОбласть("Секция_"+ДляОбласти);
				Область.Параметры.Заполнить(СтрокаПолучено);
				Область.Параметры["СтрСумма"+Окончание] = СтрСуммы.Получить(инд-1).Значение;
				Область.Параметры.инд = инд;
				ТабДокумент.Вывести(Область);
				инд=инд+1;
			Конецесли;
		КонецЦикла;
		
		Для итер=1 по 4-инд цикл
			Область = Макет.ПолучитьОбласть("Секция_"+(ДляОбласти+Итер));
			Область.Параметры.инд = инд+итер-1;
			ТабДокумент.Вывести(Область);
		КонецЦикла;
		
		Область = Макет.ПолучитьОбласть("Секция_12");
		Область.Параметры.СтрИтогоПолучено=СтрИтогоПолучено;
		Область.Параметры.СтрИзрасходовано=СтрИзрасходовано;
		ТабДокумент.Вывести(Область);
		
		Область = Макет.ПолучитьОбласть("ПослеТаблицы");
		Область.Параметры.СтрИзрасходовано = СтрИзрасходовано;
		Область.Параметры.ПредставлениеГода = Лев(Число(Год(Дата)),4);
		Область.Параметры.СтрКонечныйОстаток = СтрКонечныйОстаток;
		Область.Параметры.СтрИзрасходованоПрописью = СтрИзрасходованоПрописью;
		Область.Параметры.СтрКонечныйПерерасход = СтрКонечныйПерерасход;
		Область.Параметры.ПриложеноДок = ПриложеноДок;
		Область.Параметры.КонечныйОстатокПерерасход = СтрКонечныйОстаток + СтрКонечныйПерерасход;
		ТабДокумент.Вывести(Область);
		
		//ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		
		ТабДокумент.Вывести(Макет.ПолучитьОбласть("Шапка"));
		
		Область = Макет.ПолучитьОбласть("Строка");
		
		//РезРасходы.Сбросить();
		//СтрокаРасх = РезРасходы.Выбрать ();  		
		Для каждого СтрокаРасх из Расходы Цикл
			
			Если СтрокаРасх.Валюта= СтрокаВалюта Тогда
				
				//Пока СтрокаРасх.Следующий() Цикл
				Если Валюта.Пустая() Тогда
					СуммаСтроки = Формат(СтрокаРасх.Сумма,"ЧЦ=15; ЧДЦ=2; ЧРД=-");
				Иначе
					СуммаСтроки = Формат(СтрокаРасх.Сумма*Курс/Кратность,"ЧЦ=15; ЧДЦ=2; ЧРД=-")+"
					|"+Формат(СтрокаРасх.Сумма,"ЧЦ=15; ЧДЦ=2; ЧРД=-")+" "+СокрЛП(Валюта.Наименование);
				КонецЕсли;
				Область.Параметры.Заполнить(СтрокаРасх);
				Область.Параметры.Дата = ?(СтрокаРасх.ДатаПо=ПустоеЗначениеТипа(Тип("Дата")),Формат(СтрокаРасх.ДатаС, "ДФ=dd.MM.yy"),"С "+Формат(СтрокаРасх.ДатаС, "ДФ=dd.MM.yy")+ Символы.ПС+"по "+Формат(СтрокаРасх.ДатаПо, "ДФ=dd.MM.yy"));
				Область.Параметры.СуммаСтроки = СуммаСтроки;
				ТабДокумент.Вывести(Область);
			КонецЕсли;
			
		КонецЦикла;
		
		Область = Макет.ПолучитьОбласть("Подвал"); 
		//Если Валюта.Пустая() Тогда
		//	Область.Параметры.СуммаВсего = Формат(РезРасходы.СуммаРасхода,"ЧЦ=15; ЧДЦ=2; ЧРД=-");
		//Иначе
			Область.Параметры.СуммаВсего = Формат(РезРасходы.СуммаРасхода*Курс/Кратность,"ЧЦ=15; ЧДЦ=2; ЧРД=-")+"
			|"+Формат(РезРасходы.СуммаРасхода,"ЧЦ=15; ЧДЦ=2; ЧРД=-")+" "+СокрЛП(СтрокаВалюта.Наименование);
		//КонецЕсли;
		ТабДокумент.Вывести(Область);
		ДопКНомеру = ДопКНомеру + 1 ;
	КонецЦикла;
	
	Возврат ТабДокумент;
	
	Конецесли; 	
	
КонецФункции	

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
	
	// Получить экземпляр документа на печать
	
	ТабДокумент = ПечатьАвансовогоОтчета();
	
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, СформироватьЗаголовокДокумента(Ссылка), НепосредственнаяПечать);
	
КонецПроцедуры // Печать()

//#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("Печать","Печать");
	
КонецФункции // ПолучитьСтруктуруПечатныхФорм()

Процедура ДвиженияПоРегистрам(РежимПроведения,  Отказ, Заголовок, СтруктураШапкиДокумента)
	
	ДвиженияПоБУ(РежимПроведения, Отказ, Заголовок ,СтруктураШапкиДокумента);
	
КонецПроцедуры

Процедура ДвиженияПоБУ(Режим, Отказ, Заголовок ,СтруктураШапкиДокумента)
	
	ПроводкиБУ = Движения.Хозрасчетный;	
	
	Для Каждого СтрокаРасходы Из Расходы Цикл
		
		Если НЕ МногоВалютный Тогда 				
			ВалютаВПроводке =Валюта;
		Иначе
			ВалютаВПроводке=СтрокаРасходы.Валюта;
		КонецЕсли;
		
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание = СтрокаРасходы.НазначениеРасхода;     
		
		Если ИспользоватьЕдиныйСчетЗатрат Тогда
			Проводка.СчетДт      = СчетЗатрат;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Субконто1);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Субконто2);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Субконто3);
		Иначе
			Проводка.СчетДт      = СтрокаРасходы.СчетЗатрат;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаРасходы.Субконто1);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаРасходы.Субконто2);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаРасходы.Субконто3);
		КонецЕсли; 
		Если Проводка.СчетДт.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.НайтиПоКоду("1000")) И Проводка.СчетДт<>ПланыСчетов.Хозрасчетный.НайтиПоКоду("1070") Тогда
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Ссылка);
		КонецЕсли;
		
		Если Проводка.СчетДт.Количественный Тогда
			Проводка.КоличествоДт=СтрокаРасходы.Количество;
		КонецЕсли;	
		
		Проводка.СчетКт     =  СчетУчетаСотрудника;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Сотрудник);
		Если СчетУчетаСотрудника.Валютный Тогда
			Проводка.ВалютаКт=ВалютаВПроводке;
			Проводка.ВалютнаяСуммаКт=СтрокаРасходы.Сумма;
			Проводка.Сумма=СтрокаРасходы.Сумма*ПолучитьКурсВалюты(ВалютаВПроводке,КонецДня(Дата)).Курс;
		Иначе	
			Проводка.Сумма = СтрокаРасходы.Сумма; 
		КонецЕсли;
		
		
		
		Если СтрокаРасходы.СуммаНДС<>0 Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание = "";     
			Проводка.СчетДт      = СчетУчетаПлатежа("НДС");
			УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 1, Справочники.ПлатежиВБюджет.НДС);
			Проводка.СчетКт     =  СчетУчетаСотрудника;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Сотрудник);
			Если СчетУчетаСотрудника.Валютный Тогда
				Проводка.ВалютаКт=ВалютаВПроводке;
				Проводка.ВалютнаяСуммаКт=СтрокаРасходы.СуммаНДС;
				Проводка.Сумма=СтрокаРасходы.СуммаНДС*ПолучитьКурсВалюты(ВалютаВПроводке,КонецДня(Дата)).Курс;
			Иначе	
				Проводка.Сумма = СтрокаРасходы.СуммаНДС; 
			КонецЕсли;	
		КонецЕсли; 
	КонецЦикла; 
	
	Для Каждого Строка Из Получено Цикл
		
		Если не Строка.Провести Тогда
			Продолжить;
		КонецЕсли;
		
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Период      = Строка.Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание = "";     
		
		Проводка.СчетДт      = Строка.СчетАванса;
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Сотрудник);
		
		Проводка.СчетКт     =  Строка.СчетКредит;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Строка.Субконто1);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Строка.Субконто2);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,Строка.Субконто3);
		
		Если Строка.СчетКредит.Валютный Тогда
			
			ВалютаПроводки=?(МногоВалютный,Строка.Валюта,Валюта);
			
			Проводка.ВалютаКт=ВалютаПроводки;
			Проводка.ВалютнаяСуммаКт=Строка.Сумма;
			Проводка.Сумма=Строка.Сумма*ПолучитьКурсВалюты(ВалютаПроводки,КонецДня(Строка.Дата)).Курс;
			
			Если Строка.СчетАванса.Валютный Тогда
				Проводка.ВалютаДт=ВалютаПроводки;
				Проводка.ВалютнаяСуммаДт=Строка.Сумма;
			КонецЕсли;	
			
		Иначе	
			Проводка.Сумма = Строка.Сумма; 
		КонецЕсли;	
		
		
	КонецЦикла;
	
	//ПроводкиБУ.Записать();
	
	
	//Если (Не ТипОтчета ИЛИ МногоВалютный) И СчетУчетаСотрудника.Валютный Тогда
	//	ЗачетАвансов.ПереоценитьСчетБУ(ЭтотОбъект, СчетУчетаСотрудника, Сотрудник);
	//КонецЕсли; 
	
	Если ЗачестьАванс Тогда
		ПроводкиБУ.Записать();
		ЗачетАвансов.ВыполнитьЗакрытиеАвансов(ЭтотОбъект, СчетУчетаСотрудника, Сотрудник,Неопределено);
	КонецЕсли;
	

КонецПроцедуры

// Процедура - обработчик события "ОбработкаПроведения"
//
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	// Дерево значений, содержащее имена необходимых полей в запросе по шапке.
	Перем ДеревоПолейЗапросаПоШапке;
	
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	
	//ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	
	Если НЕ Отказ Тогда
		ДвиженияПоРегистрам(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента);
	КонецЕсли; 
	
КонецПроцедуры // ОбработкаПроведения()

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("Склад","Не выбран склад.");
	
	Если ИспользоватьЕдиныйСчетЗатрат Тогда
		СтруктураОбязательныхПолей.Вставить("СчетЗатрат","Не указан счет учета затрат.");
	КонецЕсли;
	
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	
	СтруктураПолей = Новый Структура();
	
	СтруктураПолей.Вставить("СчетУчетаСотрудника","Не указан счет учета сотрудника");
	
	Если НЕ ИспользоватьЕдиныйСчетЗатрат Тогда
		СтруктураПолей.Вставить("СчетЗатрат","Не указан счет учета затрат.");
	КонецЕсли;
	
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Расходы", СтруктураПолей, Отказ, Заголовок);
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если МногоВалютный тогда
		Валюта = "" ;
		СуммаПоДокументу = 0;
	Иначе
		СуммаПоДокументу = Расходы.Итог("Сумма"); 
	Конецесли;	
	
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();