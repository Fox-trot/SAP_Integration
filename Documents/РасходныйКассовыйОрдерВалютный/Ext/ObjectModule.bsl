﻿// Текущие курс и кратность валюты документа для расчетов
Перем КурсДокумента Экспорт;
Перем КратностьДокумента Экспорт;

Перем мВалютаРегламентированногоУчета Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Получение представления для документа, удостоверяющего личность
//
// Параметры
//  ДокФизЛица  – Паспортные данные физ. лица
//
// Возвращаемое значение:
//   Строка   – Представление документа, удостоверяющего личность
//
Функция ПолучитьПредставлениеДокументаФизЛица(ДокФизЛица) Экспорт
	
	Возврат Строка(ДокФизЛица.Вид) + " серия " +
	ДокФизЛица.Серия       + ", номер " +
	ДокФизЛица.Номер       + ", выданный " +
	Формат(ДокФизЛица.ДатаВыдачи, "ДФ=dd.MM.yyyy")  + " " +
	ДокФизЛица.Выдан;
	
КонецФункции // ПолучитьПредставлениеДокументаФизЛица()

Функция РубКоп(Сумма,Валюта)
	Руб=Цел(Сумма);
	Коп=ОКР(100*(Сумма-Руб),0,1);
	Если Валюта.Код="860" Тогда
		СуммаРубКоп=""+Руб+" сум. "+Цел(Коп/10)+(Коп-10*Цел(Коп/10))+" т.";
	ИначеЕсли Валюта.Код="840" Тогда
		СуммаРубКоп=""+Руб+" дол. США. "+Цел(Коп/10)+(Коп-10*Цел(Коп/10))+" цент";
	ИначеЕсли Валюта.Код="978" Тогда
		СуммаРубКоп=""+Руб+" евро "+Цел(Коп/10)+(Коп-10*Цел(Коп/10))+" евроцент";	
	КонецЕсли;	
	Возврат СуммаРубКоп;	
КонецФункции

// Функция формирует табличный документ с печатной формой накладной,
	// разработанной методистами
	//
	// Возвращаемое значение:
	//  Табличный документ - печатная форма накладной
	//
Функция ПечатьРКО()
	Макет       = ПолучитьМакет("КО2");
	ТабДокумент = Новый ТабличныйДокумент;
	
	СведенияОбОрганизации = СведенияОЮрФизЛице(Организация, ,Дата);
	
	ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
	ОбластьМакета.Параметры.ПредставлениеОрганизации = Организация.НаименованиеПолное;
	
	ОбластьМакета.Параметры.Число     				= Формат(День(Дата),"ЧВН=1,ЧГ=0");
	ОбластьМакета.Параметры.Месяц     				= Формат(Месяц(Дата),"ЧВН=1,ЧГ=0");
	ОбластьМакета.Параметры.Год       				= Формат(Год(Дата),"ЧГ=0");
	ОбластьМакета.Параметры.НомерДокумента    		= ПолучитьНомерНаПечать(ЭтотОбъект.Ссылка);
	
	ОбластьМакета.Параметры.КодАналитическогоУчета  = ШифрАналитическогоУчета;
	ОбластьМакета.Параметры.КодПодразделения		= Подразделение;
	ОбластьМакета.Параметры.СубСчет                 = КоррСчет;	
	ОбластьМакета.Параметры.КодЦелевогоНазначения   = ШифрЦелевогоНазначения;	
	ОбластьМакета.Параметры.ВидУдержания			= ВидУдержания;	
	ОбластьМакета.Параметры.ТН						= ТабельныйНомер;
	ОбластьМакета.Параметры.Курс					= Курс;
	
	ОбластьМакета.Параметры.СубСчет   				= КоррСчет;
	ОбластьМакета.Параметры.ФИОПолучателя  			= ВыдатьСтрокой;
	ОбластьМакета.Параметры.Основание  				= Основание;
	ОбластьМакета.Параметры.Приложение 				= Приложение;
	
	ОбластьМакета.Параметры.Сумма		      		= Формат(Сумма,"ЧЦ=15; ЧДЦ=2; ЧРД=.");
	ОбластьМакета.Параметры.СуммаПрописью     		= СформироватьСуммуПрописью(Сумма, ВалютаДокумента);
	
	СуммаПоКурсуПрописью="";
	СуммаПоКурсу=0;
	
	
	СуммаПоКурсу=Сумма*Курс/Кратность;
	СуммаПоКурсуПрописью=СформироватьСуммуПрописью(СуммаПоКурсу, Константы.ВалютаРегламентированногоУчета.Получить());
	ОбластьМакета.Параметры.СуммаПоКурсуПрописью=СокрЛП(СуммаПоКурсуПрописью);
	ОбластьМакета.Параметры.СуммаПоКурсу=РубКоп(СуммаПоКурсу,Константы.ВалютаРегламентированногоУчета.Получить());

	
	ТекстСуммаНДС = "";
	Если СуммаНДС=0 Тогда
		ТекстСуммаНДС = ", без НДС";
	Иначе	
		ТекстСуммаНДС = ", в т.ч. НДС ( "+Строка(СтавкаНДС)+"% ) "+ Формат(СуммаНДС, "ЧЦ=15; ЧДЦ=2; ЧРД=.; ЧН=0-00");
	КонецЕсли; 
	
	ОбластьМакета.Параметры.ТекстСуммаНДС=ТекстСуммаНДС;
	
	ОтветственныеЛица = ОтветственныеЛица(Организация, Дата);

	ОбластьМакета.Параметры.РеквизитыДокументаУдостоверяющегоЛичность=ПоДокументу;
	ОбластьМакета.Параметры.Заполнить(ОтветственныеЛица);
	
	ТабДокумент.Вывести(ОбластьМакета);
	
	// Зададим параметры макета
	ТабДокумент.ПолеСверху = 10;
	ТабДокумент.ПолеСлева  = 20;
	ТабДокумент.ПолеСнизу  = 10;
	ТабДокумент.ПолеСправа = 10;
	ТабДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Портрет;
	ТабДокумент.КлючПараметровПечати="КПП_РасходныйКассовыйОрдерВалютный";
	
	Возврат ТабДокумент;
КонецФункции // ПечатьРКО()
	
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
		Если ИмяМакета = "РКО" Тогда
			
			ТабДокумент = ПечатьРКО();
			
		КонецЕсли;
		
		НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, СформироватьЗаголовокДокумента(ЭтотОбъект, ""));
		
	КонецПроцедуры // Печать
	
// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("РКО,Бланк","Расходный кассовый ордер","Бланк");
	
КонецФункции // ПолучитьСтруктуруПечатныхФорм()
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

////////////////////////////////////////////////////////////////////////////////
//// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

Процедура ДвиженияПоБУ(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента)

	// Бухгалтерские проводки документа
	ПроводкиБУ = Движения.Хозрасчетный;
	СчетКт = СтруктураШапкиДокумента.СчетКасса;
	Проводка = ПроводкиБУ.Добавить();
	Проводка.Период      = Дата;
	Проводка.Организация = СтруктураШапкиДокумента.Организация;
	
	Проводка.Содержание = "";
	Проводка.СчетДт      = СтруктураШапкиДокумента.КоррСчет;
	УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 1, СтруктураШапкиДокумента.Субконто1);
	УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 2, СтруктураШапкиДокумента.Субконто2);
	УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 3, СтруктураШапкиДокумента.Субконто3);
	
	Проводка.СчетКт = СчетКт;
	УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Касса);
	УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,СтатьяДвиженияДенежныхСредств);
	
	Если Проводка.СчетДт.Валютный Тогда
		Проводка.ВалютаДт        = СтруктураШапкиДокумента.ВалютаДокумента;
		Проводка.ВалютнаяСуммаДт = СтруктураШапкиДокумента.Сумма;
	КонецЕсли;
	
	ВалютаРег       = мВалютаРегламентированногоУчета;
	ДанныеОВалюте   = ПолучитьКурсВалюты(ВалютаРег, Дата);
	
	Проводка.Сумма  = ПересчитатьИзВалютыВВалюту(СтруктураШапкиДокумента.Сумма, СтруктураШапкиДокумента.ВалютаДокумента, ВалютаРег,
												 Курс, ДанныеОВалюте.Курс, Кратность, ДанныеОВалюте.Кратность);
	
	Проводка.ВалютаКт        = СтруктураШапкиДокумента.ВалютаДокумента;
	Проводка.ВалютнаяСуммаКт = СтруктураШапкиДокумента.Сумма;
		
	
	Если Проводка.СчетДт.Количественный Тогда
		Проводка.КоличествоДт        = СтруктураШапкиДокумента.Количество;
	КонецЕсли;
КонецПроцедуры	

Процедура ДвиженияПоРегистрам(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента)
	
	ДвиженияПоБУ(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента);
		
КонецПроцедуры

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок,СтруктураШапкиДокумента)
	
	//Проверяем заполнение шапки
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("СчетКасса","Не указан счет учета денежных средств.");
	
	Если (СчетКасса.Валютный) или (КоррСчет.Валютный) Тогда
		СтруктураОбязательныхПолей.Вставить("Валюта","Не указана валюта документа.");
	КонецЕсли;
	
	СтруктураОбязательныхПолей.Вставить("КоррСчет","Не указан корреспондирующий счет.");
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, Режим)
	
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	//ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
		
		//Если (ВалютаДокумента <> мВалютаРегламентированногоУчета) тогда
		//	ПереоценкаСчетовДокументаРегл(ЭтотОбъект,СтруктураШапкиДокумента, мВалютаРегламентированногоУчета,Отказ);
		//КонецЕсли; 	

	КонецЕсли;
	
КонецПроцедуры // ОбработкаПроведения

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Кратность=0 Тогда
		Кратность=1;
	КонецЕсли;	
	
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
