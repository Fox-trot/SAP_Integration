﻿
Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	ДобавитьПрефиксУзла(Префикс);
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	ДвиженияПоРегистрам(Режим, Отказ, Заголовок,СтруктураШапкиДокумента);
		
КонецПроцедуры

Процедура ДвиженияПоРегистрам(Режим, Отказ, Заголовок,СтруктураШапкиДокумента)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РезервыНоменклатурыПродажОстатки.Номенклатура,
	|	РезервыНоменклатурыПродажОстатки.Склад,
	|	РезервыНоменклатурыПродажОстатки.ДокументРезервирования,
	|	РезервыНоменклатурыПродажОстатки.КоличествоОстаток КАК Количество,
	|	РезервыНоменклатурыПродажОстатки.Контрагент
	|ИЗ
	|	РегистрНакопления.РезервыНоменклатурыПродаж.Остатки(
	|			&ДатаОстатка,
	|			Организация = &Организация
	|				И ДокументРезервирования В
	|					(ВЫБРАТЬ
	|						РеализацияМедикаментов.ДокументРезервирования
	|					ИЗ
	|						Документ.РеализацияМедикаментов КАК РеализацияМедикаментов
	|					ГДЕ
	|						РеализацияМедикаментов.Проведен
	|						И РеализацияМедикаментов.ДокументРезервирования <> ЗНАЧЕНИЕ(Документ.РезервированиеМедикаментов.ПустаяСсылка))) КАК РезервыНоменклатурыПродажОстатки";

	Запрос.УстановитьПараметр("ДатаОстатка", КонецДня(Дата)+1);
	Запрос.УстановитьПараметр("Организация", Организация);

	Результат = Запрос.Выполнить();

	Выборка = Результат.Выбрать();

	Пока Выборка.Следующий() Цикл

		Движение=Движения.РезервыНоменклатурыПродаж.Добавить();
		ЗаполнитьЗначенияСвойств(Движение,Выборка);
		Движение.ВидДвижения=ВидДвиженияНакопления.Расход;
		Движение.Организация=Организация;
		Движение.Период=Дата;
		
	КонецЦикла;

	Движения.РезервыНоменклатурыПродаж.Записать();
	
КонецПроцедуры
