﻿
Перем ТаблицаЗачетаНДС;
Перем ПорядокУплатыНДС;

////////////////////////////////////////////////////////////////////////////////

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	Возврат Новый Структура("","");
КонецФункции

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	//Проверяем заполнение шапки
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	Если НЕ КонтрАгентВТаблице Тогда 
		СтруктураОбязательныхПолей.Вставить("Контрагент","Не выбран контрагент");
		СтруктураОбязательныхПолей.Вставить("ДоговорКонтрагента","Не выбран договор");
	КонецЕсли;
	Если ИспользоватьЕдиныйСчетЗатрат Тогда
		СтруктураОбязательныхПолей.Вставить("СчетЗатрат","Не указан счет учета затрат.");
	КонецЕсли;
	СтруктураОбязательныхПолей.Вставить("СчетРасчетовСКонтрагентом","Не указан счет учета расчетов с контрагентом.");
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	//Проверяем заполнение табличной части 
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("ОписаниеУслуги","Не заполнено описание услуги");
	Если КонтрАгентВТаблице Тогда 
		СтруктураПолей.Вставить("Контрагент","Не выбран контрагент");
		СтруктураПолей.Вставить("ДоговорКонтрагента","Не выбран договор");
	КонецЕсли;
	Если НЕ ИспользоватьЕдиныйСчетЗатрат Тогда
		СтруктураПолей.Вставить("СчетЗатрат","Не указан счет учета затрат.");
	КонецЕсли;
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Услуги", СтруктураПолей, Отказ, Заголовок);
КонецПроцедуры

Процедура ПрверитьЗачетНДС(Отказ)
	Для каждого СтрокаТЧ Из Услуги Цикл
		Если СтрокаТЧ.СуммаНДС<>0 И НЕ ЗначениеЗаполнено(СтрокаТЧ.ЗачетНДС) Тогда
			Отказ=Истина;
			Сообщить("В таблице УСЛУГИ в строке № "+Строка(СтрокаТЧ.НомерСтроки)+" не заполнен зачет НДС");
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура ЗаписатьПлатежиПоНДС()
	Для Каждого СтрокаТЧ Из Услуги Цикл
		Если СтрокаТЧ.СуммаНДС=0 Тогда
			Продолжить;
		КонецЕсли;
		Если НЕ СтрокаТЧ.СчетЗатрат.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А0800) Тогда
			Продолжить;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Субконто1) Тогда
			Продолжить;
		КонецЕсли;
		Если СтрокаТЧ.ЗачетНДС<>Перечисления.ЗачетНДС.НДСПо_ОС_НМА_НС И
			 СтрокаТЧ.ЗачетНДС<>Перечисления.ЗачетНДС.НДСВЗачетИмущество Тогда
			Продолжить;
		КонецЕсли; 
		//
		Если ЗначениеЗаполнено(СтрокаТЧ.ПлатежПоНДС) Тогда
			ОбъектПлатеж = СтрокаТЧ.ПлатежПоНДС.ПолучитьОбъект();
		Иначе
			ПлатежПоНДС = ПолучитьПлатежПоНДС(Ссылка,СтрокаТЧ.Субконто1);
			Если ЗначениеЗаполнено(ПлатежПоНДС) Тогда
				ОбъектПлатеж = ПлатежПоНДС.ПолучитьОбъект();
			Иначе
				ОбъектПлатеж = Справочники.ПлатежиПоНДС.СоздатьЭлемент();
				ОбъектПлатеж.Наименование = СтрокаТЧ.Субконто1.Наименование;
				ОбъектПлатеж.Номенклатура = СтрокаТЧ.Субконто1;
				ОбъектПлатеж.ДокументПоступления = Ссылка;
				ОбъектПлатеж.УстановитьНовыйКод();
			КонецЕсли;
		КонецЕсли;
		ОбъектПлатеж.ДатаНачала = Дата;
		ОбъектПлатеж.СтавкаНДС = СтрокаТЧ.СтавкаНДС;
		Если СтрокаТЧ.ЗачетНДС=Перечисления.ЗачетНДС.НДСВЗачетИмущество Тогда
			ОбъектПлатеж.КоличествоМесяцев = 36;
		ИначеЕсли СтрокаТЧ.ЗачетНДС=Перечисления.ЗачетНДС.НДСПо_ОС_НМА_НС Тогда
			ОбъектПлатеж.КоличествоМесяцев = 12;
		КонецЕсли;
		ОбъектПлатеж.ОбменДанными.Загрузка=Истина;
		ОбъектПлатеж.Записать();
		СтрокаТЧ.ПлатежПоНДС=ОбъектПлатеж.Ссылка;
	КонецЦикла;
	Записать(РежимЗаписиДокумента.Запись);
КонецПроцедуры

Функция СформироватьОписаниеПервичногоДокумента(ПервичныйДокумент)
	ПервичныйДокументСтр=сокрлп(ПервичныйДокумент);	
    Если лев(ПервичныйДокументСтр,1)="№" или ЭтоЦифра(лев(ПервичныйДокументСтр,1)) Тогда
		Возврат "Сч.фак. "+ПервичныйДокументСтр;	
	Иначе
		Возврат ПервичныйДокументСтр;
	КонецЕсли; 
КонецФункции

////////////////////////////////////////////////////////////////////////////////

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	СуммаПоДокументу = Услуги.Итог("Сумма")+Услуги.Итог("СуммаНДС");
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	Для Каждого СтрокаТЧ Из Услуги Цикл
		Если ЗначениеЗаполнено(СтрокаТЧ.ПлатежПоНДС) Тогда
			СтрокаТЧ.ПлатежПоНДС="";
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	ПрверитьЗачетНДС(Отказ);
	Если НЕ Отказ Тогда
		ЗаписатьПлатежиПоНДС();
		ДвиженияПоБУ(Отказ,Заголовок,СтруктураШапкиДокумента);
	КонецЕсли;
КонецПроцедуры

Процедура ДвиженияПоБУ(Отказ,Заголовок,СтруктураШапкиДокумента)
	ПорядокУплатыНДС = ПолучитьПорядокУплатыНДС(Дата,Организация);
	ПроводкиБУ = Движения.Хозрасчетный;
	ТаблицаЗачетаНДС = СоздатьТаблицуДляУчетаНДС();
	Для Каждого СтрокаУслуги Из Услуги Цикл
		Если ИспользоватьЕдиныйСчетЗатрат Тогда
			СчетДт = СчетЗатрат;
			СубконтоДт1 = Субконто1;
			СубконтоДт2 = Субконто2;
			СубконтоДт3 = Субконто3;
		Иначе
			СчетДт = СтрокаУслуги.СчетЗатрат;
			СубконтоДт1 = СтрокаУслуги.Субконто1;
			СубконтоДт2 = СтрокаУслуги.Субконто2;
			СубконтоДт3 = СтрокаУслуги.Субконто3;
		КонецЕсли; 
		Если КонтрАгентВТаблице Тогда 
			КонтрагентВПроводку=СтрокаУслуги.Контрагент;
			ДоговорКонтрагентаВПроводку=СтрокаУслуги.ДоговорКонтрагента;
			ПриходныйДокументВПроводку=СтрокаУслуги.ПриходныйДокумент;
			ПриходныйДокументДатаВПроводку=СтрокаУслуги.ПриходныйДокументДата;
		Иначе 
			КонтрагентВПроводку=Контрагент;
			ДоговорКонтрагентаВПроводку=ДоговорКонтрагента;
			ПриходныйДокументВПроводку=ПриходныйДокумент;
			ПриходныйДокументДатаВПроводку=ПриходныйДокументДата;
		Конецесли;
		////
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание	 = СтрокаУслуги.ОписаниеУслуги;     
		//
		Проводка.СчетДт = СчетДт;
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СубконтоДт1);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СубконтоДт2);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СубконтоДт3);
		Если Проводка.СчетДт.КоличественныйСЗ Тогда
			Проводка.КоличествоСЗДт = СтрокаУслуги.Количество;
		КонецЕсли;
		//
		Проводка.СчетКт = СчетРасчетовСКонтрагентом;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,КонтрагентВПроводку);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,ДоговорКонтрагентаВПроводку);
		Если СчетРасчетовСКонтрагентом.Валютный Тогда
			Проводка.ВалютаКт = Валюта;
			Проводка.ВалютнаяСуммаКт = СтрокаУслуги.Сумма; 
			Проводка.Сумма = СтрокаУслуги.Сумма*Курс; 
		Иначе
			Проводка.Сумма = СтрокаУслуги.Сумма; 
		КонецЕсли; 
		////
		Если СтрокаУслуги.СуммаНДС<>0 Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = СтрокаУслуги.ОписаниеУслуги;     
			//
			Если Дата<Дата('20190101') И (СчетДт.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А0700) ИЛИ
										  СчетДт.ПринадлежитЭлементу(ПланыСчетов.Хозрасчетный.А0800)) Тогда
				Проводка.СчетДт = СчетДт;
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СубконтоДт1);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СубконтоДт2);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СубконтоДт3);
			ИначеЕсли Дата<Дата('20190101') Тогда
				Проводка.СчетДт = СчетУчетаАвансаПлатежа("НДС");
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"НалогиИОбязательныеПлатежи",Справочники.ПлатежиВБюджет.НДС);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"СтавкиНДС",СтрокаУслуги.СтавкаНДС);
			ИначеЕсли ПорядокУплатыНДС = Перечисления.ПорядокУплатыНДС.Общеустановленный Тогда
				Если СтрокаУслуги.ЗачетНДС=Перечисления.ЗачетНДС.НДСВЗачет Тогда
					Проводка.СчетДт = СчетУчетаАвансаПлатежа("НДС");
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"НалогиИОбязательныеПлатежи",Справочники.ПлатежиВБюджет.НДС);
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"СтавкиНДС",СтрокаУслуги.СтавкаНДС);
				ИначеЕсли СтрокаУслуги.ЗачетНДС=Перечисления.ЗачетНДС.НДСПо_ОС_НМА_НС ИЛИ
						  СтрокаУслуги.ЗачетНДС=Перечисления.ЗачетНДС.НДСВЗачетИмущество Тогда
					Проводка.СчетДт = ПланыСчетов.Хозрасчетный.А4401;
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"ПлатежиПоНДС",СтрокаУслуги.ПлатежПоНДС);
				ИначеЕсли СтрокаУслуги.ЗачетНДС=Перечисления.ЗачетНДС.НДСУслугамВСтоимость_ОС_НМА_НС Тогда
					Проводка.СчетДт = ПланыСчетов.Хозрасчетный.А4402;
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СубконтоДт1);
				Иначе
					Проводка.СчетДт = СчетДт;
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СубконтоДт1);
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СубконтоДт2);
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СубконтоДт3);
				КонецЕсли;
			Иначе
				Проводка.СчетДт = СчетДт;
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СубконтоДт1);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СубконтоДт2);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СубконтоДт3);
			КонецЕсли;	
			//
			Проводка.СчетКт = СчетРасчетовСКонтрагентом;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,КонтрагентВПроводку);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,ДоговорКонтрагентаВПроводку);
			Если СчетРасчетовСКонтрагентом.Валютный Тогда
				Проводка.ВалютаКт = Валюта;
				Проводка.ВалютнаяСуммаКт = СтрокаУслуги.СуммаНДС; 
				Проводка.Сумма = СтрокаУслуги.СуммаНДС*Курс; 
			Иначе
				Проводка.Сумма = СтрокаУслуги.СуммаНДС; 
			КонецЕсли; 
		КонецЕсли; 
		////
		КурсВПроводку=?(СчетРасчетовСКонтрагентом.Валютный,Курс,1);
		Движение = ТаблицаЗачетаНДС.Добавить();
		Движение.Период				= ?(ЗначениеЗаполнено(ПриходныйДокументДатаВПроводку),ПриходныйДокументДатаВПроводку,Дата);
		Движение.Организация		= Организация;
		Движение.СчетДт				= СчетДт;
		Движение.Получатель			= СубконтоДт1;
		Движение.СчетКт				= СчетРасчетовСКонтрагентом;
		Движение.Сумма				= СтрокаУслуги.Сумма*КурсВПроводку;
		Движение.СуммаНДСПоУслугам	= СтрокаУслуги.СуммаНДС*КурсВПроводку;
		Движение.Поставщик			= КонтрагентВПроводку;
		Движение.Договор			= ДоговорКонтрагентаВПроводку;
		Движение.ПриходныйДокумент	= ПриходныйДокументВПроводку;
		Движение.ЗачетНДС			= СтрокаУслуги.ЗачетНДС;
		Движение.СтавкаНДС			= СтрокаУслуги.СтавкаНДС;
		Движение.ПорядокУплатыНДС	= ПорядокУплатыНДС;
	КонецЦикла; 
	Для Каждого Строка Из Движения.Хозрасчетный Цикл
		Строка.ПервичныйДокумент=СформироватьОписаниеПервичногоДокумента(ПриходныйДокумент);	
	КонецЦикла;	
	ТаблицаЗачетаНДС.Свернуть("Период,Организация,СчетДт,Получатель,СчетКт,Поставщик,Договор,ПриходныйДокумент,ЗачетНДС,СтавкаНДС,ПорядокУплатыНДС","Сумма,СуммаНДС,СуммаНДСПоУслугам,СуммаНДСПоИмпорту");
	Движения.УчетЗачетаНДС.Загрузить(ТаблицаЗачетаНДС);
	Если НЕ КонтрАгентВТаблице И ЗачестьАванс Тогда
		Движения.Хозрасчетный.Записать();
		ЗачетАвансов.ВыполнитьЗакрытиеАвансов(ЭтотОбъект, СчетРасчетовСКонтрагентом, Контрагент,ДоговорКонтрагента);
	КонецЕсли;
КонецПроцедуры

Процедура ДобавитьДвижениеПоУчетуНДС(СчетДт,Получатель,СчетКт,Сумма,СуммаНДС,СуммаНДСПоУслугам,Поставщик,Договор,ПриходныйДокумент,ПриходныйДокументДата,Услуга,СтавкаНДС,ПорядокУплатыНДС)
	Движение = ТаблицаЗачетаНДС.Добавить();
	Движение.Период				= ?(ЗначениеЗаполнено(ПриходныйДокументДата), ПриходныйДокументДата, Дата);
	Движение.Организация		= Организация;
	Движение.СчетДт				= СчетДт;
	Движение.Получатель			= Получатель;
	Движение.СчетКт				= СчетКт;
	Движение.Сумма				= Сумма;
	Движение.СуммаНДС			= СуммаНДС;
	Движение.СуммаНДСПоУслугам	= СуммаНДСПоУслугам;
	Движение.Поставщик			= Поставщик;
	Движение.Договор			= Договор;
	Движение.ПриходныйДокумент	= ПриходныйДокумент;
	Движение.ЗачетНДС			= ПолучитьТипЗачетаНДС(СчетДт,Услуга);
	Движение.СтавкаНДС			= СтавкаНДС;
	Движение.ПорядокУплатыНДС	= ПорядокУплатыНДС;
КонецПроцедуры
