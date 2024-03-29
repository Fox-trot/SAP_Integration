﻿
Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	ДобавитьПрефиксУзла(Префикс);
	
КонецПроцедуры

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("Табель","Табель");
	
КонецФункции

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
КонецПроцедуры

Функция ПечатьДокумента(ИмяМакета)
	ТабДок = Новый ТабличныйДокумент;
	
	Макет = ПолучитьМакет(ИмяМакета);
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ТабельУчетаРабочегоВремениРабочееВремя.Ссылка.Дата,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.Ссылка.Подразделение КАК Подразделение,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.Сотрудник КАК Сотрудник,
	               |	РаботникиОрганизацийСрезПоследних.Должность КАК Должность,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.Дни КАК Дни,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.Часы КАК Часы,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.НочныеЧасы КАК НочныеЧасы,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.СверхурочныеЧасы КАК СверхурочныеЧасы,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.ПраздничныеДни КАК ПраздничныеДни,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д1 КАК д1,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д2 КАК д2,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д3 КАК д3,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д4 КАК д4,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д5 КАК д5,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д6 КАК д6,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д7 КАК д7,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д8 КАК д8,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д9 КАК д9,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д10 КАК д10,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д11 КАК д11,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д12 КАК д12,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д13 КАК д13,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д14 КАК д14,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д15 КАК д15,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д16 КАК д16,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д17 КАК д17,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д18 КАК д18,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д19 КАК д19,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д20 КАК д20,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д21 КАК д21,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д22 КАК д22,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д23 КАК д23,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д24 КАК д24,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д25 КАК д25,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д26 КАК д26,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д27 КАК д27,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д28 КАК д28,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д29 КАК д29,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д30 КАК д30,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.д31 КАК д31,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.ДниО КАК ДниОтпуска,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.ДниБ КАК ДниБолезни,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.ДниПр КАК ДниПрогула,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.ДниПерваяПоловина КАК ДниПерваяПоловина,
	               |	ТабельУчетаРабочегоВремениРабочееВремя.Сотрудник.Код КАК ТабельныйНомер
	               |ИЗ
	               |	Документ.ТабельУчетаРабочегоВремени.РабочееВремя КАК ТабельУчетаРабочегоВремениРабочееВремя
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций.СрезПоследних(&Дата2, Организация = &Организация) КАК РаботникиОрганизацийСрезПоследних
	               |		ПО ТабельУчетаРабочегоВремениРабочееВремя.Ссылка.Организация = РаботникиОрганизацийСрезПоследних.Организация
	               |			И ТабельУчетаРабочегоВремениРабочееВремя.Сотрудник = РаботникиОрганизацийСрезПоследних.Сотрудник
	               |ГДЕ
	               |	ТабельУчетаРабочегоВремениРабочееВремя.Ссылка = &Ссылка
	               |ИТОГИ
	               |	МАКСИМУМ(Должность),
	               |	СУММА(Дни),
	               |	СУММА(Часы),
	               |	СУММА(НочныеЧасы),
	               |	СУММА(СверхурочныеЧасы),
	               |	СУММА(ПраздничныеДни),
	               |	СУММА(ДниОтпуска),
	               |	СУММА(ДниБолезни),
	               |	СУММА(ДниПрогула),
	               |	СУММА(ДниПерваяПоловина),
	               |	МАКСИМУМ(ТабельныйНомер)
	               |ПО
	               |	Подразделение,
	               |	Сотрудник
	               |АВТОУПОРЯДОЧИВАНИЕ";
	
	Запрос.УстановитьПараметр("Дата2",КонецМесяца(Дата));  
	Запрос.УстановитьПараметр("Организация",Организация);
	Запрос.УстановитьПараметр("Подразделение",Подразделение);
	Запрос.УстановитьПараметр("Ссылка",Ссылка); 
	
	Результат = Запрос.Выполнить();
	//Результат_ =   Результат.Выгрузить().ВыбратьСтроку();
	
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ОбластьИтого = Макет.ПолучитьОбласть("Итого");
	
	Руководители = ОтветственныеЛица(Организация, КонецМесяца(Дата));

	ТабДок.Очистить();
	
	ОбластьШапка.Параметры.Руководитель=СокрЛП(Строка(Руководители.РуководительДолжность)+" "+Руководители.РуководительПредставление);
	
	ТабДок.НачатьАвтогруппировкуСтрок();  
	
	ВыборкаПодразделениеОрганизации = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);  	
	
	Пока ВыборкаПодразделениеОрганизации.Следующий() Цикл
		
		ОбластьИтого.Параметры.Заполнить(ВыборкаПодразделениеОрганизации);
		ОбластьШапка.Параметры.Организация = Организация ;
		ОбластьШапка.Параметры.ПодразделениеОрганизации = Подразделение ;  
		ОбластьШапка.Параметры.Период=ПредставлениеПериода(НачалоМесяца(Дата),КонецМесяца(Дата),"ФП=истина");
		
		ТабДок.Вывести(ОбластьШапка);
		
		ВыборкаСотрудник = ВыборкаПодразделениеОрганизации.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		НомерПП = 1;
		
		Пока ВыборкаСотрудник.Следующий() Цикл
			ВывестиСотрудника(ВыборкаСотрудник, НомерПП, Макет,ТабДок);
			НомерПП = НомерПП+1;	
		КонецЦикла;
		
		ОбластьИтого.Параметры.Заполнить(ВыборкаПодразделениеОрганизации);
		ТабДок.Вывести(ОбластьИтого);
		
	КонецЦикла;
	
	ТабДок.ЗакончитьАвтогруппировкуСтрок();
	
	ТабДок.АвтоМасштаб=Истина;
	ТабДок.ОриентацияСтраницы=ОриентацияСтраницы.Ландшафт;
	ТабДок.ФиксацияСверху=10;
	//ТабДок.ФиксацияСлева=0;
	
	Возврат ТабДок;
	
КонецФункции

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	// Получить экземпляр документа на печать
	
	ТабДокумент = ПечатьДокумента(ИмяМакета);
		
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "");
	
КонецПроцедуры // Печать()


Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	
	СтруктураОбязательныхПолей = Новый Структура();
	СтруктураОбязательныхПолей.Вставить("Организация");
	СтруктураОбязательныхПолей.Вставить("Подразделение","Не выбрано подразделение.");
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	СтруктураОбязательныхПолей = Новый Структура();
	СтруктураОбязательныхПолей.Вставить("Сотрудник","Не выбран сотрудник.");
	СтруктураОбязательныхПолей.Вставить("СпособОтраженияРасходов","Не выбран способ отражения расходов.");
	//СтруктураОбязательныхПолей.Вставить("РаспределениеСотрудниковПоВидамУслуг","Не выбрано распред. сотрудников по видам услуг.");
	СтруктураОбязательныхПолей.Вставить("ПериодДействияНачало","Не выбрано начало периода.");
	СтруктураОбязательныхПолей.Вставить("ПериодДействияКонец","Не выбран конец периода.");
	СтруктураОбязательныхПолей.Вставить("ГрафикРаботы","Не выбран график работы.");
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "РабочееВремя", СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	Если не Отказ Тогда
		Для Каждого Строка из РабочееВремя Цикл
			Если НачалоМесяца(Строка.ПериодДействияНачало)<>НачалоМесяца(Дата) Тогда
				Отказ=истина;
				Сообщить("Неверная дата начала периода!",СтатусСообщения.Важное);
			КонецЕсли;
			Если НачалоМесяца(Строка.ПериодДействияКонец)<>НачалоМесяца(Дата) Тогда
				Отказ=истина;
				Сообщить("Неверная дата окончания периода!",СтатусСообщения.Важное);
			КонецЕсли;
			Если Строка.ПериодДействияНачало>Строка.ПериодДействияКонец Тогда
				Отказ=истина;
				Сообщить("Неверный период!",СтатусСообщения.Важное);
			КонецЕсли;	
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры


Процедура ВывестиСотрудника(Выборка,НомерПП,Макет,ТабДок)
	
	Область = Макет.ПолучитьОбласть("Сотрудник");
	
	Область.Параметры.Заполнить(Выборка);
	Область.Параметры.Сотрудник=ФИОСотрудника(Выборка.Сотрудник,Дата);
	Область.Параметры.НомерПП = НомерПП ; ; 
	
	ВыборкаДетали=Выборка.Выбрать();
	Пока ВыборкаДетали.Следующий() Цикл
		
		Для н=1 по 31 Цикл
			
			Если ЗначениеЗаполнено(ВыборкаДетали["д"+Строка(н)]) Тогда
				
				Область.Параметры["д"+Строка(н)]=ВыборкаДетали["д"+Строка(н)];	
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;  	
	
	ТабДок.Вывести(Область); 
	
КонецПроцедуры	
