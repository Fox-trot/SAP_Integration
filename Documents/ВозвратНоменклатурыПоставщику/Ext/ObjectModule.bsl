﻿
Перем ТаблицаЗачетаНДС;
Перем ПорядокУплатыНДС;

////////////////////////////////////////////////////////////////////////////////

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	Возврат Новый Структура("СчетФактура","Счет-фактура");
КонецФункции

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	Если ИмяМакета="СчетФактура" Тогда
		ТабДокумент = ПечатьСчетФактура();
	КонецЕсли; 
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "Счет-фактура");
КонецПроцедуры

Функция ПечатьСчетФактура()
	
	ТабДок = Новый ТабличныйДокумент;
	
	Макет = ПолучитьМакет("СчетФактура");//+?(Дата>=Дата(2014,1,1),"2014",""));
	
	СведенияОбОрганизации = СведенияОЮрФизЛице(Организация, БанковскийСчет, Дата);
	СведенияОКонтрагенте  = СведенияОЮрФизЛице(Контрагент, БанковскийСчетКонтрагента, Дата);
	
	Область = Макет.ПолучитьОбласть("Заголовок");
	Область.Параметры.ДоговорПродажи	= ДоговорКонтрагента.Наименование;
	Область.Параметры.Номер				= ПолучитьНомерНаПечать(ЭтотОбъект);
	Область.Параметры.Дата				= Формат(Дата,"ДЛФ=D")+" г.";
	ТабДок.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть("Шапка");
	Область.Параметры.Заполнить(СведенияОбОрганизации);
	Область.Параметры.Заполнить(СведенияОКонтрагенте);
	ТабДок.Вывести(Область);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВозвратНоменклатурыПоставщикуНоменклатура.Номенклатура,
	|	ВозвратНоменклатурыПоставщикуНоменклатура.Количество,
	|	ВозвратНоменклатурыПоставщикуНоменклатура.Сумма КАК Сумма,
	|	ВозвратНоменклатурыПоставщикуНоменклатура.Номенклатура.БазоваяЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ВозвратНоменклатурыПоставщикуНоменклатура.Цена КАК Цена,
	|	ВозвратНоменклатурыПоставщикуНоменклатура.СуммаНДС КАК СуммаНДС,
	|	ВозвратНоменклатурыПоставщикуНоменклатура.СтавкаНДС,
	|	ВозвратНоменклатурыПоставщикуНоменклатура.НомерСтроки КАК НомерСтроки,
	|	ВЫБОР
	|		КОГДА ВозвратНоменклатурыПоставщикуНоменклатура.СуммаНДС = 0
	|			ТОГДА 0
	|		ИНАЧЕ ВозвратНоменклатурыПоставщикуНоменклатура.Сумма + ВозвратНоменклатурыПоставщикуНоменклатура.СуммаНДС
	|	КОНЕЦ КАК Всего,
	|	ВозвратНоменклатурыПоставщикуНоменклатура.Сумма + ВозвратНоменклатурыПоставщикуНоменклатура.СуммаНДС КАК СуммаСУчетомАкцизаИНДС
	|ИЗ
	|	Документ.ВозвратНоменклатурыПоставщику.Номенклатура КАК ВозвратНоменклатурыПоставщикуНоменклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ВозвратНоменклатурыПоставщику КАК ВозвратНоменклатурыПоставщику
	|		ПО ВозвратНоменклатурыПоставщикуНоменклатура.Ссылка = ВозвратНоменклатурыПоставщику.Ссылка
	|ГДЕ
	|	ВозвратНоменклатурыПоставщику.Ссылка = &Ссылка
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВозвратНоменклатурыПоставщикуНоменклатураПродаж.Номенклатура,
	|	ВозвратНоменклатурыПоставщикуНоменклатураПродаж.Количество,
	|	ВозвратНоменклатурыПоставщикуНоменклатураПродаж.Сумма,
	|	ВозвратНоменклатурыПоставщикуНоменклатураПродаж.Номенклатура.БазоваяЕдиницаИзмерения,
	|	ВозвратНоменклатурыПоставщикуНоменклатураПродаж.Цена,
	|	ВозвратНоменклатурыПоставщикуНоменклатураПродаж.СуммаНДС,
	|	ВозвратНоменклатурыПоставщикуНоменклатураПродаж.СтавкаНДС,
	|	ВозвратНоменклатурыПоставщикуНоменклатураПродаж.НомерСтроки,
	|	ВЫБОР
	|		КОГДА ВозвратНоменклатурыПоставщикуНоменклатураПродаж.СуммаНДС = 0
	|			ТОГДА 0
	|		ИНАЧЕ ВозвратНоменклатурыПоставщикуНоменклатураПродаж.Сумма + ВозвратНоменклатурыПоставщикуНоменклатураПродаж.СуммаНДС
	|	КОНЕЦ,
	|	ВозвратНоменклатурыПоставщикуНоменклатураПродаж.Сумма + ВозвратНоменклатурыПоставщикуНоменклатураПродаж.СуммаНДС
	|ИЗ
	|	Документ.ВозвратНоменклатурыПоставщику.НоменклатураПродаж КАК ВозвратНоменклатурыПоставщикуНоменклатураПродаж
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ВозвратНоменклатурыПоставщику КАК ВозвратНоменклатурыПоставщику
	|		ПО ВозвратНоменклатурыПоставщикуНоменклатураПродаж.Ссылка = ВозвратНоменклатурыПоставщику.Ссылка
	|ГДЕ
	|	ВозвратНоменклатурыПоставщику.Ссылка = &Ссылка
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
		Область.Параметры.номерСтроки = номерСтроки;
		ТабДок.Вывести(Область);
	КонецЦикла;
	
	Область = Макет.ПолучитьОбласть("Подвал");
	Область.Параметры.Заполнить(ВыборкаОбщие);
	
	Всего = ВыборкаОбщие.Сумма + ВыборкаОбщие.СуммаНДС;
	Область.Параметры.ВсегоПрописью	= ПроцедурыСервера.СформироватьСуммуПрописью_Сервер(Всего, Константы.ВалютаРегламентированногоУчета.Получить());
	Область.Параметры.Доверенность	= Доверенность;
	Область.Параметры.Получатель	= Получатель;
	
	Руководители = ОтветственныеЛица(Организация, Дата);	
    Область.Параметры.Заполнить(Руководители);
	ТабДок.Вывести(Область);
	
	ТабДок.ФиксацияСверху			= 0;
	ТабДок.ФиксацияСлева			= 0;
	ТабДок.ЭкземпляровНаСтранице	= 1;
	ТабДок.ТолькоПросмотр			= Истина;
	ТабДок.Автомасштаб				= Истина;
	ТабДок.ОриентацияСтраницы		= ОриентацияСтраницы.Портрет;
	ТабДок.КлючПараметровПечати="КПП_РеализацияНоменклатуры";
	
	Возврат ТабДок;
	
КонецФункции // ПечатьСчетФактура()

////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	//Проверяем заполнение шапки
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("БанковскийСчет","Не выбран вид банковский счет");
	СтруктураОбязательныхПолей.Вставить("Контрагент","Не выбран вид контрагент");
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	//Проверяем заполнение табличной части 
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("Номенклатура","Не выбрана номенклатура");
	СтруктураПолей.Вставить("СчетУчетаБУ","Не выбран счет учета номенклатуры");
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Номенклатура", СтруктураПолей, Отказ, Заголовок);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	СуммаПоДокументу=Номенклатура.Итог("Сумма");
	КоличествоПоДокументу=0;
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ПоступлениеНоменклатуры") Тогда
		ДоговорКонтрагента = ДанныеЗаполнения.ДоговорПоставщика;
		Комментарий = ДанныеЗаполнения.Комментарий;
		Организация = ДанныеЗаполнения.Организация;
		ОтражатьПоБУ = ДанныеЗаполнения.ОтражатьПоБУ;
		Контрагент = ДанныеЗаполнения.Поставщик;
		Склад = ДанныеЗаполнения.Склад;
		Документ = ДанныеЗаполнения.ссылка;
		СуммаПоДокументу = ДанныеЗаполнения.СуммаПоДокументу;
		Для Каждого ТекСтрокаНоменклатура Из ДанныеЗаполнения.Номенклатура Цикл
			НоваяСтрока = Номенклатура.Добавить();
			НоваяСтрока.Количество = ТекСтрокаНоменклатура.Количество;
			НоваяСтрока.Номенклатура = ТекСтрокаНоменклатура.Номенклатура;
			НоваяСтрока.НоменклатурныйНомер = ТекСтрокаНоменклатура.НоменклатурныйНомер;
			НоваяСтрока.СтавкаНДС = ТекСтрокаНоменклатура.СтавкаНДС;
			НоваяСтрока.Сумма = ТекСтрокаНоменклатура.Сумма;
			НоваяСтрока.СуммаНДС = ТекСтрокаНоменклатура.СуммаНДС;
			НоваяСтрока.СчетУчетаБУ = ТекСтрокаНоменклатура.СчетУчетаБУ;
			НоваяСтрока.Цена = ТекСтрокаНоменклатура.Цена;
		КонецЦикла;
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ПоступлениеНоменклатурыПродаж") Тогда
		ДоговорКонтрагента = ДанныеЗаполнения.ДоговорПоставщика;
		Комментарий = ДанныеЗаполнения.Комментарий;
		Организация = ДанныеЗаполнения.Организация;
		Ответственный = ДанныеЗаполнения.Ответственный;
		ОтражатьПоБУ = ДанныеЗаполнения.ОтражатьПоБУ;
		Контрагент = ДанныеЗаполнения.Поставщик;
		Склад = ДанныеЗаполнения.Склад;
		Документ = ДанныеЗаполнения.ссылка;
		СуммаПоДокументу = ДанныеЗаполнения.СуммаПоДокументу;
		СчетУчетаРасчетовСКонтрагентомБУ = ДанныеЗаполнения.СчетУчетаРасчетовСКонтрагентом;
		Для Каждого ТекСтрокаНоменклатура Из ДанныеЗаполнения.Номенклатура Цикл
			НоваяСтрока = НоменклатураПродаж.Добавить();
			НоваяСтрока.Количество = ТекСтрокаНоменклатура.Количество;
			НоваяСтрока.НоменклатурныйНомер = ТекСтрокаНоменклатура.НоменклатурныйНомер;
			НоваяСтрока.Номенклатура = ТекСтрокаНоменклатура.Номенклатура;
			НоваяСтрока.СтавкаНДС = ТекСтрокаНоменклатура.СтавкаНДС;
			НоваяСтрока.Сумма = ТекСтрокаНоменклатура.Сумма;
			НоваяСтрока.СуммаНДС = ТекСтрокаНоменклатура.СуммаНДС;
			НоваяСтрока.СчетУчетаБУ = ТекСтрокаНоменклатура.СчетУчетаБУ;
			НоваяСтрока.Цена = ТекСтрокаНоменклатура.Цена;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);	
	ПроверитьОстаткиНоменклатуры(Отказ,ЭтотОбъект,Номенклатура, Склад,Организация,"СчетУчетаБУ");
	ПроверитьОстаткиНоменклатурыПродаж(Отказ,ЭтотОбъект,НоменклатураПродаж, Склад,Организация,"СчетУчетаБУ","НоменклатураПродаж");
	ДвиженияПоРегистрамБУ(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
КонецПроцедуры

Процедура ДвиженияПоРегистрамБУ(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	ПорядокУплатыНДС = ПолучитьПорядокУплатыНДС(Дата,Организация);
	ТаблицаЗачетаНДС = СоздатьТаблицуДляУчетаНДС();
	ПроводкиБУ = Движения.Хозрасчетный;
	ТаблицаОстатков = Новый ТаблицаЗначений;
	ЗаполнитьТаблицуОстатковНоменклатуры(ТаблицаОстатков,ЭтотОбъект,Склад,Организация);
	Для Каждого СтрокиНоменклатура Из Номенклатура Цикл
		Себестоимость=0;
		СтрокаОстатков=ТаблицаОстатков.Найти(СтрокиНоменклатура.Номенклатура,"Субконто1");
		Если СтрокаОстатков<>неопределено Тогда
			Если СтрокаОстатков.КоличествоОстатокДт=СтрокиНоменклатура.Количество Тогда
				Себестоимость=СтрокаОстатков.СуммаОстатокДт;							
			ИначеЕсли СтрокаОстатков.КоличествоОстатокДт<>0 Тогда
				Себестоимость=СтрокаОстатков.СуммаОстатокДт/СтрокаОстатков.КоличествоОстатокДт*СтрокиНоменклатура.Количество;							
			КонецЕсли; 		
		КонецЕсли; 
		ТекущаяСуммаДопРасходов = СтрокиНоменклатура.СуммаДопРасходов;
		////
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание	 = "Возврат поставщику";     
		//
		Проводка.СчетДт = СчетУчетаРасчетовСКонтрагентомБУ;
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Контрагент);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,ДоговорКонтрагента);
		//
		Проводка.СчетКт = СтрокиНоменклатура.СчетУчетаБУ;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокиНоменклатура.Номенклатура);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Склад);
		Проводка.КоличествоКт = СтрокиНоменклатура.Количество; 
		//
		Проводка.Сумма = СтрокиНоменклатура.Сумма; 
		////
		Если СтрокиНоменклатура.СуммаНДС<>0 Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = "";     
			//
			Проводка.СчетДт = СобирательныйСчет;
			//
			Если ПорядокУплатыНДС = Перечисления.ПорядокУплатыНДС.Общеустановленный Тогда
				Проводка.СчетКт =  СчетУчетаПлатежа("НДС");
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,"НалогиИОбязательныеПлатежи",Справочники.ПлатежиВБюджет.НДС);
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,"СтавкиНДС",СтрокиНоменклатура.СтавкаНДС);
			Иначе
				Проводка.СчетКт = СтрокиНоменклатура.СчетУчетаБУ;
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокиНоменклатура.Номенклатура);
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Склад);
			КонецЕсли; 
			//
			Проводка.Сумма = СтрокиНоменклатура.СуммаНДС; 
		КонецЕсли; 
		////
		Движение = ТаблицаЗачетаНДС.Добавить();
		Движение.Период				= ?(ЗначениеЗаполнено(Документ), Документ.ПриходныйДокументДата, Дата);
		Движение.Организация		= Организация;
		Движение.СчетДт				= СтрокиНоменклатура.СчетУчетаБУ;
		Движение.Получатель			= Склад;
		Движение.СчетКт				= СчетУчетаРасчетовСКонтрагентомБУ;
		Движение.Сумма				=-СтрокиНоменклатура.Сумма;
		Движение.СуммаНДС			=-СтрокиНоменклатура.СуммаНДС;
		Движение.Поставщик			= Контрагент;
		Движение.Договор			= ДоговорКонтрагента;
		Движение.ПриходныйДокумент	= ?(ЗначениеЗаполнено(Документ), Документ.ПриходныйДокумент, Номер);
		Движение.ЗачетНДС			= ПолучитьТипЗачетаНДС(СтрокиНоменклатура.СчетУчетаБУ);
		Движение.СтавкаНДС			= СтрокиНоменклатура.СтавкаНДС;
		Движение.ПорядокУплатыНДС	= ПорядокУплатыНДС;
	КонецЦикла;
	Для Каждого СтрокаНоменклатуры Из НоменклатураПродаж Цикл
		Если СтрокаНоменклатуры.СчетУчетаБУ.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А004) Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = "Возврат  номенклатуры ";     
			//
			Проводка.СчетКт = СтрокаНоменклатуры.СчетУчетаБУ;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаНоменклатуры.Номенклатура);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Склад);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,Контрагент);
			Проводка.КоличествоКт = СтрокаНоменклатуры.Количество;
			//
			Проводка.Сумма = СтрокаНоменклатуры.Сумма; 
		Иначе	
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = "Возврат номенклатуры ";     
			//
			Проводка.СчетДт = СчетУчетаРасчетовСКонтрагентомБУ;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Контрагент);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,ДоговорКонтрагента);
			//
			Проводка.СчетКт = СтрокаНоменклатуры.СчетУчетаБУ;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаНоменклатуры.Номенклатура);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Склад);
			Проводка.КоличествоКт = СтрокаНоменклатуры.Количество;
			//
			Проводка.Сумма = СтрокаНоменклатуры.Сумма; 
			////
			Если СтрокаНоменклатуры.СуммаНДС<>0 Тогда
				Проводка = ПроводкиБУ.Добавить();
				Проводка.Период      = Дата;
				Проводка.Организация = Организация;
				Проводка.Содержание	 = "Поступление НДС";     
				//
				Проводка.СчетДт = СчетУчетаРасчетовСКонтрагентомБУ;
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Контрагент);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,ДоговорКонтрагента);
				//
				Если ПорядокУплатыНДС = Перечисления.ПорядокУплатыНДС.Общеустановленный Тогда
					Проводка.СчетКт =  СчетУчетаПлатежа("НДС");
					УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,"НалогиИОбязательныеПлатежи",Справочники.ПлатежиВБюджет.НДС);
					УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,"СтавкиНДС",СтрокаНоменклатуры.СтавкаНДС);
				Иначе
					Проводка.СчетКт = СтрокаНоменклатуры.СчетУчетаБУ;
					УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаНоменклатуры.Номенклатура);
					УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Склад);
				КонецЕсли; 
				//
				Проводка.Сумма = СтрокаНоменклатуры.СуммаНДС; 
			КонецЕсли; 
			////
			Движение = ТаблицаЗачетаНДС.Добавить();
			Движение.Период				= ?(ЗначениеЗаполнено(Документ) , ?(ЗначениеЗаполнено(Документ.ПриходныйДокументДата),Документ.ПриходныйДокументДата,Дата), Дата);
			Движение.Организация		= Организация;
			Движение.СчетДт				= СтрокаНоменклатуры.СчетУчетаБУ;
			Движение.Получатель			= Склад;
			Движение.СчетКт				= СчетУчетаРасчетовСКонтрагентомБУ;
			Движение.Сумма				=-СтрокаНоменклатуры.Сумма;
			Движение.СуммаНДС			=-СтрокаНоменклатуры.СуммаНДС;
			Движение.Поставщик			= Контрагент;
			Движение.Договор			= ДоговорКонтрагента;
			Движение.ПриходныйДокумент	= ?(ЗначениеЗаполнено(Документ), Документ.ПриходныйДокумент, Номер);
			Движение.ЗачетНДС			= ПолучитьТипЗачетаНДС(СтрокаНоменклатуры.СчетУчетаБУ);
			Движение.СтавкаНДС			= СтрокиНоменклатура.СтавкаНДС;
			Движение.ПорядокУплатыНДС	= ПорядокУплатыНДС;
		КонецЕсли;
	КонецЦикла; 
	ТаблицаЗачетаНДС.Свернуть("Период,Организация,СчетДт,Получатель,СчетКт,Поставщик,Договор,ПриходныйДокумент,ЗачетНДС,СтавкаНДС,ПорядокУплатыНДС","Сумма,СуммаНДС,СуммаНДСПоУслугам,СуммаНДСПоИмпорту");	
	Движения.УчетЗачетаНДС.Загрузить(ТаблицаЗачетаНДС);
	Движения.Хозрасчетный.Записать();
КонецПроцедуры	 
