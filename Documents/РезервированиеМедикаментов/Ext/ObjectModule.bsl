﻿
Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	ДобавитьПрефиксУзла(Префикс);
	
КонецПроцедуры

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("СчетФактура","Счет-фактура");
	
КонецФункции

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	СуммаПоДокументу=Номенклатура.Итог("Сумма")+Номенклатура.Итог("СуммаНДС");
	КоличествоПоДокументу=0;
	
	Если не Ссылка.Пустая() Тогда
	Если ЕстьРеализация() И РежимЗаписи <> РежимЗаписиДокумента.Запись Тогда
		Отказ=Истина;
		Сообщить("По данному документу введена реализация, изменение невозможно!");	
	КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Функция ЕстьРеализация()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РеализацияМедикаментов.Ссылка
	|ИЗ
	|	Документ.РеализацияМедикаментов КАК РеализацияМедикаментов
	|ГДЕ
	|	РеализацияМедикаментов.ДокументРезервирования = &ДокументРезервирования
	|	И НЕ РеализацияМедикаментов.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("ДокументРезервирования", Ссылка);
	
	Результат = Запрос.Выполнить();

	Возврат не Результат.Пустой();

КонецФункции

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	
	//Проверяем заполнение шапки
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("БанковскийСчет","Не выбран вид банковский счет");
	СтруктураОбязательныхПолей.Вставить("Контрагент","Не выбран вид контрагент");
	
	
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	//Проверяем заполнение табличной части 
	
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("Номенклатура","Не выбрана номенклатура");
	
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Номенклатура", СтруктураПолей, Отказ, Заголовок);
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);	
	
	ПроверитьОстаткиНоменклатурыПродаж(Отказ,ЭтотОбъект,Номенклатура, Склад,Организация,"СчетУчетаБУ");
	ДвиженияПоРегистрам(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
	
КонецПроцедуры

Процедура ДвиженияПоРегистрам(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	
	Для Каждого Строка Из Номенклатура Цикл
		
		Движение=Движения.РезервыНоменклатурыПродаж.ДобавитьПриход();
		Движение.Организация=Организация;
		Движение.Период=Дата;
		Движение.Склад=Склад;
		Движение.Номенклатура=Строка.Номенклатура;
		Движение.Количество=Строка.Количество;
		Движение.ДокументРезервирования=Ссылка;
		Движение.Контрагент = Контрагент;
		Движение.КоличествоАкций = Строка.КоличествоАкция;
		
	КонецЦикла;	
			
КонецПроцедуры

Функция ПечатьСчетФактура()
	
	ТабДок = Новый ТабличныйДокумент;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РезервированиеМедикаментовНоменклатура.Номенклатура,
	|	РезервированиеМедикаментовНоменклатура.Количество,
	|	РезервированиеМедикаментовНоменклатура.Сумма КАК Сумма,
	|	РезервированиеМедикаментовНоменклатура.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	РезервированиеМедикаментовНоменклатура.Цена КАК Цена,
	|	РезервированиеМедикаментовНоменклатура.СуммаНДС КАК СуммаНДС,
	|	РезервированиеМедикаментовНоменклатура.СтавкаНДС,
	|	РезервированиеМедикаментовНоменклатура.СрокГодности,
	|	РезервированиеМедикаментовНоменклатура.НомерСтроки КАК НомерСтроки,
	|	ВЫБОР
	|		КОГДА РезервированиеМедикаментовНоменклатура.СуммаНДС = 0
	|			ТОГДА 0
	|		ИНАЧЕ РезервированиеМедикаментовНоменклатура.Сумма + РезервированиеМедикаментовНоменклатура.СуммаНДС
	|	КОНЕЦ КАК Всего,
	|	РезервированиеМедикаментовНоменклатура.Сумма + РезервированиеМедикаментовНоменклатура.СуммаНДС КАК СуммаСУчетомАкцизаИНДС,
	|	РезервированиеМедикаментовНоменклатура.Серия,
	|	РезервированиеМедикаментовНоменклатура.Себестоимость,
	|	РезервированиеМедикаментовНоменклатура.Наценка,
	|	РезервированиеМедикаментовНоменклатура.Номенклатура.ПроисхождениеТовара КАК Происхождение
	|ИЗ
	|	Документ.РезервированиеМедикаментов.Номенклатура КАК РезервированиеМедикаментовНоменклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РезервированиеМедикаментов КАК РезервированиеМедикаментов
	|		ПО РезервированиеМедикаментовНоменклатура.Ссылка = РезервированиеМедикаментов.Ссылка
	|ГДЕ
	|	РезервированиеМедикаментов.Ссылка = &Ссылка
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
	
	//==================================================
	
	Если Дата<Дата(2019,01,22) Тогда
		Макет = ПолучитьМакет("СчетФактура2018");
	Иначе 	
		Макет = ПолучитьМакет("СчетФактура");
	КонецЕсли;
	
	
	СведенияОбОрганизации = СведенияОЮрФизЛице(Организация, БанковскийСчет, Дата);
	СведенияОКонтрагенте  = СведенияОЮрФизЛице(Контрагент, БанковскийСчетКонтрагента, Дата);
	
	Область = Макет.ПолучитьОбласть("Заголовок");
	Область.Параметры.ДоговорПродажи	= ДоговорКонтрагента.Наименование;
	Область.Параметры.Номер				= ПолучитьНомерНаПечать(ЭтотОбъект);
	Область.Параметры.Дата				= Формат(Дата,"ДЛФ=D")+" г.";
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
		Область.Параметры.номерСтроки = номерСтроки;
		ТабДок.Вывести(Область);
	КонецЦикла;
	
	Если ФинансоваяСкидкаПроцент=0 И флФинСкидка = ЛОжь Тогда
		Область = Макет.ПолучитьОбласть("Подвал");
	Иначе
		Область = Макет.ПолучитьОбласть("ПодвалСкидка");
	КонецЕсли;
	
	Область.Параметры.Заполнить(ВыборкаОбщие);
	
	Всего=0;
	
	Попытка
		Всего = ВыборкаОбщие.Сумма + ВыборкаОбщие.СуммаНДС;
	Исключение
	КонецПопытки;
	
	
	Руководители = ОтветственныеЛица(Организация, Дата);	
    Область.Параметры.Заполнить(Руководители);
	
	Если ФинансоваяСкидкаПроцент=0 И флФинСкидка = ЛОжь Тогда
		Область.Параметры.ВсегоПрописью	= СформироватьСуммуПрописью(Всего, Константы.ВалютаРегламентированногоУчета.Получить());
	Иначе
		Область.Параметры.ФинансоваяСкидкаПроцент=ФинансоваяСкидкаПроцент;
  		Область.Параметры.ФинансоваяСкидкаСумма=ФинансоваяСкидкаСумма+?(флФинСкидка,ФинСкидка2,0);
  		Область.Параметры.СуммаБезСкидки=Всего-ФинансоваяСкидкаСумма-?(флФинСкидка,ФинСкидка2,0);
		Область.Параметры.ВсегоПрописью	= СформироватьСуммуПрописью(Всего-ФинансоваяСкидкаСумма-?(флФинСкидка,ФинСкидка2,0), Константы.ВалютаРегламентированногоУчета.Получить());
	КонецЕсли;
	
	ТабДок.Вывести(Область);
	
	ТабДок.ФиксацияСверху			= 0;
	ТабДок.ФиксацияСлева			= 0;
	//ТабДок.ЭкземпляровНаСтранице	= 1;
	ТабДок.ТолькоПросмотр			= Истина;
	ТабДок.Автомасштаб				= Истина;
	ТабДок.ОриентацияСтраницы		= ОриентацияСтраницы.Ландшафт;
	
	ТабДок.КлючПараметровПечати="КПП_РеализацияМедикаментов";
	
	Возврат ТабДок;
	
КонецФункции // ПечатьСчетФактура()

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	Если ИмяМакета="СчетФактура" Тогда
		ТабДокумент = ПечатьСчетФактура();
	КонецЕсли; 
	
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "Счет-фактура");
	
КонецПроцедуры // Печать()
