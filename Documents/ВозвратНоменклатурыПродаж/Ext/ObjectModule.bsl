﻿
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	Возврат Новый Структура("СчетФактура","Счет-фактура");
КонецФункции

Процедура Печать(ИмяМакета, КоличествоЭкземпляров=1, НаПринтер=Ложь, НепосредственнаяПечать=Ложь) Экспорт
	Если ИмяМакета="СчетФактура" Тогда
		ТабДокумент = ПечатьСчетФактура();
	КонецЕсли; 
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "Счет-фактура");
КонецПроцедуры

Функция ПечатьСчетФактура()
	
	ТабДок = Новый ТабличныйДокумент;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВозвратНоменклатурыПродажНоменклатура.Номенклатура,
	|	ВозвратНоменклатурыПродажНоменклатура.Количество,
	|	ВозвратНоменклатурыПродажНоменклатура.Сумма КАК Сумма,
	|	ВозвратНоменклатурыПродажНоменклатура.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ВозвратНоменклатурыПродажНоменклатура.Цена КАК Цена,
	|	ВозвратНоменклатурыПродажНоменклатура.СуммаНДС КАК СуммаНДС,
	|	ВозвратНоменклатурыПродажНоменклатура.СтавкаНДС,
	|	ВозвратНоменклатурыПродажНоменклатура.НомерСтроки КАК НомерСтроки,
	|	ВЫБОР
	|		КОГДА ВозвратНоменклатурыПродажНоменклатура.СуммаНДС = 0
	|			ТОГДА 0
	|		ИНАЧЕ ВозвратНоменклатурыПродажНоменклатура.Сумма + ВозвратНоменклатурыПродажНоменклатура.СуммаНДС
	|	КОНЕЦ КАК Всего,
	|	ВозвратНоменклатурыПродажНоменклатура.Сумма + ВозвратНоменклатурыПродажНоменклатура.СуммаНДС КАК СуммаСУчетомАкцизаИНДС,
	|	ВозвратНоменклатурыПродажНоменклатура.КоличествоАкция,
	|	ВозвратНоменклатурыПродажНоменклатура.Себестоимость,
	|	ВозвратНоменклатурыПродажНоменклатура.СчетУчетаБУ,
	|	NULL КАК СчетУчета,
	|	ВозвратНоменклатурыПродажНоменклатура.Номенклатура.Серия КАК Серия,
	|	ВозвратНоменклатурыПродажНоменклатура.Наценка
	|ИЗ
	|	Документ.ВозвратНоменклатурыПродаж.Номенклатура КАК ВозвратНоменклатурыПродажНоменклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ВозвратНоменклатурыПродаж КАК ВозвратНоменклатурыПродаж
	|		ПО ВозвратНоменклатурыПродажНоменклатура.Ссылка = ВозвратНоменклатурыПродаж.Ссылка
	|ГДЕ
	|	ВозвратНоменклатурыПродаж.Ссылка = &Ссылка
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВозвратНоменклатурыПродажУслуги.Услуга,
	|	NULL,
	|	ВозвратНоменклатурыПродажУслуги.Сумма,
	|	ВозвратНоменклатурыПродажУслуги.Услуга.БазоваяЕдиницаИзмерения,
	|	NULL,
	|	ВозвратНоменклатурыПродажУслуги.СуммаНДС,
	|	ВозвратНоменклатурыПродажУслуги.СтавкаНДС,
	|	ВозвратНоменклатурыПродажУслуги.НомерСтроки,
	|	ВЫБОР
	|		КОГДА ВозвратНоменклатурыПродажУслуги.СуммаНДС = 0
	|			ТОГДА 0
	|		ИНАЧЕ ВозвратНоменклатурыПродажУслуги.Сумма + ВозвратНоменклатурыПродажУслуги.СуммаНДС
	|	КОНЕЦ,
	|	ВозвратНоменклатурыПродажУслуги.Сумма + ВозвратНоменклатурыПродажУслуги.СуммаНДС,
	|	NULL,
	|	NULL,
	|	NULL,
	|	ВозвратНоменклатурыПродажУслуги.СчетУчета,
	|	NULL,
	|	NULL
	|ИЗ
	|	Документ.ВозвратНоменклатурыПродаж.Услуги КАК ВозвратНоменклатурыПродажУслуги
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ВозвратНоменклатурыПродаж КАК ВозвратНоменклатурыПродаж
	|		ПО ВозвратНоменклатурыПродажУслуги.Ссылка = ВозвратНоменклатурыПродаж.Ссылка
	|ГДЕ
	|	ВозвратНоменклатурыПродаж.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки
	|ИТОГИ
	|	СУММА(Сумма),
	|	СУММА(СуммаНДС),
	|	СУММА(Всего),
	|	СУММА(СуммаСУчетомАкцизаИНДС)
	|ПО
	|	ОБЩИЕ";
	
	Запрос.УстановитьПараметр("Ссылка",Ссылка );
	
	Результат = Запрос.Выполнить();
	ВыборкаОбщие = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ВыборкаОбщие.Следующий();
	
	//ПДН(
	//====Получение реквизитов из корректировачного документа====
	
	 	//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	ЗапросРМ = Новый Запрос;
	ЗапросРМ.Текст = 
		"ВЫБРАТЬ
		|	РеализацияМедикаментовНоменклатура.Номенклатура,
		|	РеализацияМедикаментовНоменклатура.Наценка,
		|	РеализацияМедикаментовНоменклатура.СрокГодности
		|ИЗ
		|	Документ.РеализацияМедикаментов.Номенклатура КАК РеализацияМедикаментовНоменклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияМедикаментов КАК РеализацияМедикаментов
		|		ПО РеализацияМедикаментовНоменклатура.Ссылка = РеализацияМедикаментов.Ссылка
		|ГДЕ
		|	РеализацияМедикаментов.Ссылка = &Ссылка";
	
	ЗапросРМ.УстановитьПараметр("Ссылка", КорректируемыйДокументРеализации.Ссылка);
	
	РезультатЗапросаРМ = ЗапросРМ.Выполнить();
	
	ВыборкаДетальныеЗаписиРМ = РезультатЗапросаРМ.Выбрать();
	
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

	
	
	//)ПДН
	//==================================================
	
	//ПДН(
	//Если Дата<Дата(2019,1,22) Тогда
	//	Макет = ПолучитьМакет("СчетФактура2017");
	//Иначе 	
		Макет = ПолучитьМакет("СчетФактура2020");
	//КонецЕсли;
	//)ПДН

	СведенияОбОрганизации = СведенияОЮрФизЛице(Организация, БанковскийСчет, Дата);
	СведенияОКонтрагенте  = СведенияОЮрФизЛице(Контрагент, БанковскийСчетКонтрагента, Дата);
	
	Если ПечататьАкт Тогда
		
		Всего = ВыборкаОбщие.Сумма + ВыборкаОбщие.СуммаНДС;
		
		Область = Макет.ПолучитьОбласть("ЗаголовокАкт");
		Область.Параметры.ФИОДиректораВЛице	= "_______________________";
		Область.Параметры.КонтрагентВЛице	= ?(ЗначениеЗаполнено(КонтрагентВЛице),КонтрагентВЛице,"_______________________");
		Область.Параметры.КонтрагентНаОсновании	= ?(ЗначениеЗаполнено(КонтрагентНаОсновании),КонтрагентНаОсновании,"___________________");
		Область.Параметры.ДоговорПродажи	= ДоговорКонтрагента.Наименование;
		Область.Параметры.Дата				= Формат(Дата,"ДЛФ=D")+" г.";
		Область.Параметры.Всего				= Формат(Всего,"ЧДЦ=2");
		Область.Параметры.Заполнить(СведенияОбОрганизации);
		Область.Параметры.Заполнить(СведенияОКонтрагенте);
		ТабДок.Вывести(Область);
		
		Область = Макет.ПолучитьОбласть("ШапкаАкт");
		ТабДок.Вывести(Область);
		
		номерСтроки = 0;
		
		Выборка = ВыборкаОбщие.Выбрать();
		Пока Выборка.Следующий() Цикл
			номерСтроки = номерСтроки+1;
			Если Выборка.СтавкаНДС = Перечисления.СтавкиНДС.БезНДС ИЛИ
				Выборка.СтавкаНДС = Перечисления.СтавкиНДС.ПустаяСсылка()Тогда
				Область = Макет.ПолучитьОбласть("СтрокаАктБезНДС");
			Иначе	
				Область = Макет.ПолучитьОбласть("СтрокаАкт");
			КонецЕсли;
									
			Область.Параметры.Заполнить(Выборка);
			Область.Параметры.номерСтроки = номерСтроки;
			ТабДок.Вывести(Область);
		КонецЦикла;
		
		Область = Макет.ПолучитьОбласть("ПодвалАкт");
		Область.Параметры.Заполнить(ВыборкаОбщие);
		
		Область.Параметры.ВсегоПрописью	= ПроцедурыСервера.СформироватьСуммуПрописью_Сервер(Всего, Константы.ВалютаРегламентированногоУчета.Получить());
		
		//Руководители = ОтветственныеЛица(Организация, Дата);	
		//Область.Параметры.Заполнить(Руководители);
		ТабДок.Вывести(Область);
		
	КонецЕсли;
	
	Область = Макет.ПолучитьОбласть("Заголовок");
	Область.Параметры.ДоговорПродажи	= ДоговорКонтрагента.Наименование;
	Область.Параметры.Номер				= ПолучитьНомерНаПечать(ЭтотОбъект);
	Область.Параметры.Дата				= Формат(Дата,"ДЛФ=D")+" г.";
	Область.Параметры.Коррекция	= "Корректируется счет - фактура № "+ПолучитьНомерНаПечать(КорректируемыйДокументРеализации)+" от "+Формат(КорректируемыйДокументРеализации.Дата,"ДФ='dd.MM.yyyy ""г.""'");
	ТабДок.Вывести(Область);
	
	Если Контрагент.ЮрФизЛицо=Перечисления.ЮрФизЛицо.ФизЛицо Тогда
		Область = Макет.ПолучитьОбласть("ШапкаФизЛицо");
	Иначе	
		Область = Макет.ПолучитьОбласть("Шапка");
	КонецЕсли;
	Область.Параметры.Заполнить(СведенияОбОрганизации);
	Область.Параметры.Заполнить(СведенияОКонтрагенте);
	ТабДок.Вывести(Область);
	
	номерСтроки = 0;
	
	Выборка = ВыборкаОбщие.Выбрать();
						
				
				
		Пока Выборка.Следующий() Цикл
		номерСтроки = номерСтроки+1;
		Если Выборка.СтавкаНДС = Перечисления.СтавкиНДС.БезНДС ИЛИ
			 Выборка.СтавкаНДС = Перечисления.СтавкиНДС.ПустаяСсылка()Тогда
			Область = Макет.ПолучитьОбласть("СтрокаБезНДС");
		Иначе	
			Область = Макет.ПолучитьОбласть("Строка");
		КонецЕсли;
		
		Область.Параметры.Заполнить(Выборка);
		Область.Параметры.Наценка = Выборка.Наценка;
		
		//Пока ВыборкаДетальныеЗаписиРМ.Следующий() Цикл
		//	Если Выборка.Номенклатура = ВыборкаДетальныеЗаписиРМ.Номенклатура Тогда
		//		 Область.Параметры.Наценка = ВыборкаДетальныеЗаписиРМ.Наценка;
		//		 ВыборкаДетальныеЗаписиРМ.Сбросить();
		//		 Прервать;
		//	КонецЕсли;
		//КонецЦикла;
		
		Область.Параметры.номерСтроки = номерСтроки;
		ТабДок.Вывести(Область);
	КонецЦикла;
		
				
	
		
	Область = Макет.ПолучитьОбласть("Подвал");
	Область.Параметры.Заполнить(ВыборкаОбщие);
	
	Попытка
		Всего = ВыборкаОбщие.Сумма + ВыборкаОбщие.СуммаНДС;
		Область.Параметры.ВсегоПрописью	= ПроцедурыСервера.СформироватьСуммуПрописью_Сервер(Всего, Константы.ВалютаРегламентированногоУчета.Получить());
	Исключение
	КонецПопытки;
	Если Дата<Дата(2019,1,22) Тогда
		Область.Параметры.Доверенность	= ПолучитьНомерНаПечать(Доверенность)+" от "+Формат(Доверенность.Дата,"ДФ='dd.MM.yyyy ""г.""'");
		Область.Параметры.Получатель	= ФИОСотрудника(Доверенность.Сотрудник,Дата);
	КонецЕсли;
	
	Руководители = ОтветственныеЛица(Организация, Дата);	
    Область.Параметры.Заполнить(Руководители);
	ТабДок.Вывести(Область);
	
	ТабДок.ФиксацияСверху			= 0;
	ТабДок.ФиксацияСлева			= 0;
	//ТабДок.ЭкземпляровНаСтранице	= 1;
	ТабДок.ТолькоПросмотр			= Истина;
	ТабДок.Автомасштаб				= Истина;
	ТабДок.ОриентацияСтраницы		= ОриентацияСтраницы.Портрет;
	
	ТабДок.КлючПараметровПечати="КПП_РеализацияНоменклатурыПродаж";
	
	Возврат ТабДок;
	
КонецФункции // ПечатьСчетФактура()

////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("БанковскийСчет","Не выбран вид банковский счет");
	СтруктураОбязательныхПолей.Вставить("Контрагент","Не выбран вид контрагент");
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	//
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("Номенклатура","Не выбрана номенклатура");
	СтруктураПолей.Вставить("СчетУчетаБУ","Не выбран счет учета номенклатуры");
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Номенклатура", СтруктураПолей, Отказ, Заголовок);
КонецПроцедуры

Процедура ДвиженияПоРегистрамБУ(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	ТаблицаИСФ = СоздатьТаблицуИСФ();
	Счет9040=ПланыСчетов.Хозрасчетный.А9040;
	Для Каждого СтрокиНоменклатура Из Номенклатура Цикл
		КоличествоВПроводку=ПеревестиКоличествоВЕдиницуХраненияОстатка(СтрокиНоменклатура.Количество,СтрокиНоменклатура.Номенклатура,СтрокиНоменклатура.ЕдиницаИзмерения);
		Если НЕ ОсобыеСчетаУчетаДоходовИСебестоимости Тогда
			Если СтрокиНоменклатура.Номенклатура.ВидНоменклатуры=Перечисления.ВидыНоменклатурыПродаж.Продукция Тогда
				СчетСебестоимости = ПланыСчетов.Хозрасчетный.НайтиПоКоду("9110");
				СчетПрибыли = ПланыСчетов.Хозрасчетный.НайтиПоКоду("9010");
			ИначеЕсли СтрокиНоменклатура.Номенклатура.ВидНоменклатуры=Перечисления.ВидыНоменклатурыПродаж.Товар Тогда
				СчетСебестоимости = ПланыСчетов.Хозрасчетный.НайтиПоКоду("9120");
				СчетПрибыли = ПланыСчетов.Хозрасчетный.НайтиПоКоду("9020");
			ИначеЕсли СтрокиНоменклатура.Номенклатура.ВидНоменклатуры=Перечисления.ВидыНоменклатурыПродаж.Работа ИЛИ
					  СтрокиНоменклатура.Номенклатура.ВидНоменклатуры=Перечисления.ВидыНоменклатурыПродаж.Услуга Тогда
				СчетСебестоимости = ПланыСчетов.Хозрасчетный.НайтиПоКоду("9130");
				СчетПрибыли = ПланыСчетов.Хозрасчетный.НайтиПоКоду("9030");
			КонецЕсли;	
		Иначе
			СчетСебестоимости = СчетУчетаСебестоимости;
			СчетПрибыли = СчетУчетаДоходов;
		КонецЕсли;
		//
		Если СтрокиНоменклатура.Номенклатура.ВидНоменклатуры=Перечисления.ВидыНоменклатурыПродаж.Продукция ИЛИ
			 СтрокиНоменклатура.Номенклатура.ВидНоменклатуры=Перечисления.ВидыНоменклатурыПродаж.Товар Тогда
			Проводка = Движения.Хозрасчетный.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = "";     
			//
			Проводка.СчетДт = СтрокиНоменклатура.СчетУчетаБУ;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокиНоменклатура.Номенклатура);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Склад);
			//Проводка.КоличествоДт = - КоличествоВПроводку; //Руслан 26-05-2019
			Проводка.КоличествоДт = КоличествоВПроводку;     //Руслан 26-05-2019
			//
			Проводка.СчетКт = СчетСебестоимости;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокиНоменклатура.Номенклатура);
			Проводка.Сумма = Окр(СтрокиНоменклатура.Себестоимость * СтрокиНоменклатура.Количество,2);
		КонецЕсли;
		////
		Проводка = Движения.Хозрасчетный.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание  = "";     
		//
		Проводка.СчетДт = Счет9040;
		//
		Проводка.СчетКт = СчетУчетаРасчетовСКонтрагентомБУ;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Контрагент);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,ДоговорКонтрагента);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,Ссылка);
		//
		Проводка.Сумма = СтрокиНоменклатура.Сумма;
		////
		Проводка = Движения.Хозрасчетный.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание	 = "";     
		//
		Проводка.СчетДт =  СчетПрибыли;
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокиНоменклатура.Номенклатура);
		//
		Проводка.СчетКт = Счет9040;
		//
		Проводка.Сумма = СтрокиНоменклатура.Сумма;
		////
		//Возврат стоимости акции //Руслан 07-06-2019
		Если СтрокиНоменклатура.КоличествоАкция <> 0 Тогда 
			Проводка = Движения.Хозрасчетный.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание = "Учтен возват фин. скидки";     
			
			Проводка.СчетКт     =  ПланыСчетов.Хозрасчетный.А9050;
			
			Проводка.СчетДт      = СчетУчетаРасчетовСКонтрагентомБУ;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Контрагент);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,ДоговорКонтрагента);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Ссылка);
			
			Проводка.Сумма = СтрокиНоменклатура.КоличествоАкция * СтрокиНоменклатура.Цена;
			
			//Проводка = Движения.Хозрасчетный.Добавить();
			//Проводка.Период      = Дата;
			//Проводка.Организация = Организация;
			//Проводка.Содержание = "Списана возват фин. скидка";     
			//
			//Проводка.СчетДт     =  ПланыСчетов.Хозрасчетный.А9020;
			//
			//Проводка.СчетКт      = ПланыСчетов.Хозрасчетный.А9050;
			//
			//Проводка.Сумма = -СтрокиНоменклатура.КоличествоАкция * СтрокиНоменклатура.Цена; 
		КонецЕсли;
		//Возврат стоимости акции //Руслан 07-06-2019
		Если СтрокиНоменклатура.СуммаНДС<>0 Тогда
			Проводка = Движения.Хозрасчетный.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = "";     
			//
			Проводка.СчетДт = СчетУчетаПлатежа("НДС");
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"СтавкиНДС",СтрокиНоменклатура.СтавкаНДС);
			//
			Проводка.СчетКт = СчетУчетаРасчетовСКонтрагентомБУ;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Контрагент);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,ДоговорКонтрагента);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,Ссылка);
			//
			Проводка.Сумма = -СтрокиНоменклатура.СуммаНДС; 
		КонецЕсли; 
		////
		Движение = ТаблицаИСФ.Добавить();
		Движение.Период				= Дата;
		Движение.Организация		= Организация;
		Движение.Контрагент			= Контрагент;
		Движение.Ссылка				= Ссылка;
		Движение.Документ			= ПолучитьНомерНаПечать(Ссылка.ПолучитьОбъект())+" от "+Формат(Ссылка.Дата, "ДФ='dd.MM.yyyy ""г.""'");
		Движение.ДокументНомер		= ПолучитьНомерНаПечать(Ссылка.ПолучитьОбъект());
		Движение.ДокументДата		= Дата;
		Движение.СтавкаНДС			= СтрокиНоменклатура.СтавкаНДС;
		Движение.ВидДеятельностиНДС	= СтрокиНоменклатура.Номенклатура.ВидДеятельностиНДС;
		Движение.ПорядокУплатыНДС	= ПолучитьПорядокУплатыНДС(Дата,Организация);
		Движение.Сумма				= СтрокиНоменклатура.Сумма;
		Движение.СуммаНДС			= СтрокиНоменклатура.СуммаНДС;
		Движение.Всего				= СтрокиНоменклатура.Всего;
	КонецЦикла;
	
	Если ФинансоваяСкидкаСумма<>0 Тогда
		
		Проводка = Движения.Хозрасчетный.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание = "Учтена фин. скидка";     
		
		Проводка.СчетКт     =  ПланыСчетов.Хозрасчетный.А9050;
		
		Проводка.СчетДт      = СчетУчетаРасчетовСКонтрагентомБУ;
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Контрагент);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,ДоговорКонтрагента);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Ссылка);
		
		Проводка.Сумма = ФинансоваяСкидкаСумма; 
		
		//Проводка = Движения.Хозрасчетный.Добавить();
		//Проводка.Период      = Дата;
		//Проводка.Организация = Организация;
		//Проводка.Содержание = "Списана фин. скидка";     
		//
		//Проводка.СчетДт     =  ПланыСчетов.Хозрасчетный.А9020;
		//
		//Проводка.СчетКт      = ПланыСчетов.Хозрасчетный.А9050;
		//
		//Проводка.Сумма = -ФинансоваяСкидкаСумма; 
		
	КонецЕсли;
	
	////
	Для Каждого СтрокиУслуги Из Услуги Цикл
		Если НЕ ОсобыеСчетаУчетаДоходовИСебестоимости Тогда
			СчетПрибыли = ПланыСчетов.Хозрасчетный.НайтиПоКоду("9030");
		Иначе
			СчетСебестоимости = СчетУчетаСебестоимости;
			СчетПрибыли = СчетУчетаДоходов;
		КонецЕсли;
		////
		Проводка = Движения.Хозрасчетный.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание	 = "";     
		//
		Проводка.СчетДт = СчетУчетаРасчетовСКонтрагентомБУ;
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Контрагент);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,ДоговорКонтрагента);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Ссылка);
		//
		Проводка.СчетКт = СчетПрибыли;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокиУслуги.Услуга);
		//
		Проводка.Сумма = СтрокиУслуги.Сумма;
		////
		Если СтрокиУслуги.СуммаНДС<>0 Тогда
			Проводка = Движения.Хозрасчетный.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = "";     
			//
			Проводка.СчетДт = СчетУчетаРасчетовСКонтрагентомБУ;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Контрагент);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,ДоговорКонтрагента);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Ссылка);
			//
			Проводка.СчетКт = СчетУчетаПлатежа("НДС");
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,"СтавкиНДС",СтрокиУслуги.СтавкаНДС);
			//
			Проводка.Сумма = СтрокиУслуги.СуммаНДС; 
		КонецЕсли; 
		////
		Движение = ТаблицаИСФ.Добавить();
		Движение.Период				= Дата;
		Движение.Организация		= Организация;
		Движение.Контрагент			= Контрагент;
		Движение.Ссылка				= Ссылка;
		Движение.Документ			= ПолучитьНомерНаПечать(Ссылка.ПолучитьОбъект())+" от "+Формат(Ссылка.Дата, "ДФ='dd.MM.yyyy ""г.""'");
		Движение.ДокументНомер		= ПолучитьНомерНаПечать(Ссылка.ПолучитьОбъект());
		Движение.ДокументДата		= Дата;
		Движение.СтавкаНДС			= СтрокиУслуги.СтавкаНДС;
		Движение.ВидДеятельностиНДС	= СтрокиУслуги.Услуга.ВидДеятельностиНДС;
		Движение.ПорядокУплатыНДС	= ПолучитьПорядокУплатыНДС(Дата,Организация);
		Движение.Сумма				= СтрокиУслуги.Сумма;
		Движение.СуммаНДС			= СтрокиУслуги.СуммаНДС;
		Движение.Всего				= СтрокиУслуги.Всего;
	КонецЦикла;
	ТаблицаИСФ.Свернуть("Период,Организация,Контрагент,Ссылка,Документ,ДокументНомер,ДокументДата,СтавкаНДС,ВидДеятельностиНДС,ПорядокУплатыНДС","Сумма,СуммаНДС,Всего");	
	Движения.ИсходящиеСчетаФактуры.Загрузить(ТаблицаИСФ);
КонецПроцедуры	 

Процедура ДвиженияПоРегистрам(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	Для Каждого Строка Из Номенклатура Цикл
		Движение = Движения.Продажи.Добавить();
		Движение.Период			 = Дата;
		Движение.Организация	 = Организация;
		Движение.Склад			 = Склад;
		Движение.Контрагент		 = Контрагент;
		Движение.Договор		 = ДоговорКонтрагента;
		Движение.Номенклатура	 = Строка.Номенклатура;
		Движение.ВидОборота		 = Перечисления.ВидыОборотовПоПродажам.Возврат;
		Движение.Валюта			 = Справочники.Валюты.ПустаяСсылка();
		Движение.Количество		 = Строка.Количество*Строка.ЕдиницаИзмерения.Коэффициент;
		Движение.Сумма			 = Строка.Сумма;
		Движение.СуммаНДС		 = Строка.СуммаНДС;
		Движение.СуммаВВалюте	 = 0;
		Движение.СуммаНДСВВалюте = 0;
	КонецЦикла;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	Для Каждого СтрокаТЧ Из Номенклатура Цикл
		Если СтрокаТЧ.Всего=0 Тогда
			СтрокаТЧ.Всего = СтрокаТЧ.Сумма+СтрокаТЧ.СуммаНДС;
		КонецЕсли;
	КонецЦикла;
	Для Каждого СтрокаТЧ Из Услуги Цикл
		Если СтрокаТЧ.Всего=0 Тогда
			СтрокаТЧ.Всего = СтрокаТЧ.Сумма+СтрокаТЧ.СуммаНДС;
		КонецЕсли;
	КонецЦикла;
	СуммаПоДокументу=Номенклатура.Итог("Всего")+Услуги.Итог("Всего");
	КоличествоПоДокументу=0;
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка) Экспорт
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.РеализацияНоменклатурыПродаж") Тогда
		БанковскийСчет					 = ДанныеЗаполнения.БанковскийСчет;
		БанковскийСчетКонтрагента		 = ДанныеЗаполнения.БанковскийСчетКонтрагента;
		ДоговорКонтрагента				 = ДанныеЗаполнения.ДоговорКонтрагента;
		Контрагент						 = ДанныеЗаполнения.Контрагент;
		Склад							 = ДанныеЗаполнения.Склад;
		КорректируемыйДокументРеализации = ДанныеЗаполнения.Ссылка;
		СчетУчетаРасчетовСКонтрагентомБУ = ДанныеЗаполнения.СчетУчетаРасчетовСКонтрагентомБУ;
		Для Каждого ТекСтрокаНоменклатура Из ДанныеЗаполнения.Номенклатура Цикл
			НоваяСтрока = Номенклатура.Добавить();
			НоваяСтрока.НоменклатурныйНомер	= ТекСтрокаНоменклатура.НоменклатурныйНомер;
			НоваяСтрока.Номенклатура		= ТекСтрокаНоменклатура.Номенклатура;
			НоваяСтрока.ЕдиницаИзмерения	= ТекСтрокаНоменклатура.ЕдиницаИзмерения;
			НоваяСтрока.СчетУчетаБУ			= ТекСтрокаНоменклатура.СчетУчетаБУ;
			НоваяСтрока.Количество			=-ТекСтрокаНоменклатура.Количество;
			НоваяСтрока.Цена				= ТекСтрокаНоменклатура.Цена;
			НоваяСтрока.Сумма				=-ТекСтрокаНоменклатура.Сумма;
			НоваяСтрока.СтавкаНДС			= ТекСтрокаНоменклатура.СтавкаНДС;
			НоваяСтрока.СуммаНДС			=-ТекСтрокаНоменклатура.СуммаНДС;
			НоваяСтрока.Всего				=-ТекСтрокаНоменклатура.Всего;
		КонецЦикла;
		Для Каждого ТекСтрокаУслуги Из ДанныеЗаполнения.Услуги Цикл
			НоваяСтрока = Услуги.Добавить();
			НоваяСтрока.Услуга		= ТекСтрокаУслуги.Услуга;
			НоваяСтрока.СчетУчета	= ТекСтрокаУслуги.СчетУчета;
			НоваяСтрока.Сумма		=-ТекСтрокаУслуги.Сумма;
			НоваяСтрока.СтавкаНДС	= ТекСтрокаУслуги.СтавкаНДС;
			НоваяСтрока.СуммаНДС	=-ТекСтрокаУслуги.СуммаНДС;
			НоваяСтрока.Всего		=-ТекСтрокаУслуги.Всего;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);	
	ДвиженияПоРегистрамБУ(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
	ДвиженияПоРегистрам(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
КонецПроцедуры

Функция ПолучитьСебестоимостьКорректируемыйДокументРеализации(КорректируемыйДокРеализации, НоменклатураСтроки) Экспорт
	СебестоимостьНоменклатуры = 0;
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВЫРАЗИТЬ(ХозрасчетныйОбороты.СуммаОборотКт / ХозрасчетныйОбороты.КоличествоОборотКт КАК ЧИСЛО(15, 2)) КАК Себестоимость
		|ИЗ
		|	РегистрБухгалтерии.Хозрасчетный.Обороты(, , Регистратор, Счет В ИЕРАРХИИ (ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.А2900)), ЗНАЧЕНИЕ(ПланВидовХарактеристик.ВидыСубконтоХозрасчетные.НоменклатураПродаж), , , ) КАК ХозрасчетныйОбороты
		|ГДЕ
		|	ХозрасчетныйОбороты.Регистратор = &Регистратор
		|	И (ХозрасчетныйОбороты.Регистратор ССЫЛКА Документ.РеализацияМедикаментов
		|			ИЛИ ХозрасчетныйОбороты.Регистратор ССЫЛКА Документ.РеализацияНоменклатурыПродаж)
		|	И ХозрасчетныйОбороты.Субконто1 = &Субконто1
		|	И ХозрасчетныйОбороты.КоличествоОборотКт > 0";
	
	Запрос.УстановитьПараметр("Регистратор", КорректируемыйДокРеализации);
	Запрос.УстановитьПараметр("Субконто1", НоменклатураСтроки);
	ВыборкаДетальныеЗаписи = Запрос.Выполнить().Выбрать();
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		СебестоимостьНоменклатуры = ВыборкаДетальныеЗаписи.Себестоимость;
	КонецЕсли;
	Возврат СебестоимостьНоменклатуры;
КонецФункции

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Если Номенклатура.Количество() = 0 И Услуги.Количество() = 0 Тогда
		ПроверяемыеРеквизиты.Добавить("Номенклатура");
	КонецЕсли;
КонецПроцедуры
