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
	
	Если ДокФизЛица=Неопределено Тогда
		Возврат "";
	Иначе	
	Возврат Строка(ДокФизЛица.Вид) + " серия " +
	ДокФизЛица.Серия       + "№ " +
	ДокФизЛица.Номер       + ", выдан " +
	Формат(ДокФизЛица.ДатаВыдачи, "ДФ=dd.MM.yyyy")  + " " +
	ДокФизЛица.Выдан;
	КонецЕсли;
	
КонецФункции // ПолучитьПредставлениеДокументаФизЛица()

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
	
	ОбластьМакета.Параметры.СубСчет   				= КоррСчет;
	ОбластьМакета.Параметры.ФИОПолучателя  			= ?(Выдать.Пустая(),ВыдатьСтрокой,Выдать);	                                     
	//ОбластьМакета.Параметры.ПаспортДанныеПолучателя	= 
	ОбластьМакета.Параметры.Основание  				= Основание;
	ОбластьМакета.Параметры.Приложение 				= Приложение;
		
	ОбластьМакета.Параметры.Сумма		      		= Формат(Сумма,"ЧЦ=15; ЧДЦ=2; ЧРД=.");
	ОбластьМакета.Параметры.СуммаПрописью     		= ПроцедурыСервера.СформироватьСуммуПрописью_Сервер(Сумма, мВалютаРегламентированногоУчета);
	ОбластьМакета.Параметры.РеквизитыДокументаУдостоверяющегоЛичность=ПоДокументу;
	//?(Выдать.Пустая(),"",ПолучитьПредставлениеДокументаФизЛица(ПаспортныеДанные(Выдать.ФизическоеЛицо,Дата)));
	
	ТекстСуммаНДС = "";
	Если СуммаНДС=0 Тогда
		ТекстСуммаНДС = ", без НДС";
	Иначе	
		ТекстСуммаНДС = ", в т.ч. НДС ( "+Строка(СтавкаНДС)+"% ) "+ Формат(СуммаНДС, "ЧЦ=15; ЧДЦ=2; ЧРД=.; ЧН=0-00");
	КонецЕсли; 
	
	ОбластьМакета.Параметры.ТекстСуммаНДС=ТекстСуммаНДС;
	
	ОтветственныеЛица = ОтветственныеЛица(Организация, Дата);
	
	ОбластьМакета.Параметры.Заполнить(ОтветственныеЛица);
	ТабДокумент.Вывести(ОбластьМакета);
	
	// Зададим параметры макета
	ТабДокумент.ПолеСверху = 10;
	ТабДокумент.ПолеСлева  = 20;
	ТабДокумент.ПолеСнизу  = 10;
	ТабДокумент.ПолеСправа = 10;
	ТабДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Портрет;
	ТабДокумент.АвтоМасштаб = Истина;
	ТабДокумент.КлючПараметровПечати="КПП_РасходныйКассовыйОрдер";
	
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
	
	Возврат Новый Структура("РКО","Расходный кассовый ордер");
	
КонецФункции // ПолучитьСтруктуруПечатныхФорм()

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
	Проводка.Сумма  = СтруктураШапкиДокумента.Сумма-СуммаНДС;
	
	Если Проводка.СчетДт.Количественный Тогда
		Проводка.КоличествоДт        = СтруктураШапкиДокумента.Количество;
	КонецЕсли;
	
	Если Не СуммаНДС = 0 Тогда
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = СтруктураШапкиДокумента.Организация;
		Проводка.Содержание = "НДС";
		Проводка.СчетКт      = СчетКасса;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Касса);
		УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 2, СтатьяДвиженияДенежныхСредств);
		Проводка.СчетДт = СчетУчетаАвансаПлатежа("НДС");                        
		Проводка.Сумма = СуммаНДС;
	КонецЕсли; 
	
КонецПроцедуры	

Процедура ДвиженияПоРегистрам(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента)
	
	ДвиженияПоБУ(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента);
	
	Если КоррСчет.Код="6710" И НЕ Субконто1 = Справочники.Сотрудники.ПустаяСсылка() Тогда
		
		Сведения = СведенияОСотруднике(Субконто1,Организация,Дата);
		Движение = Движения.Удержания.Добавить();
		Движение.Сторно				= Ложь;
		Движение.ВидРасчета			= ВидРасчета;
		Движение.ПериодРегистрации	= Дата;
		Движение.Организация		= Организация;
		Движение.Сотрудник			= Субконто1;
		Движение.Результат			= Сумма;
		Движение.ДатаНачала			= НачалоМесяца(Дата);
		Движение.ДатаОкончания		= КонецМесяца(Дата);
		Движение.Подразделение		= Сведения.Подразделение;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок,СтруктураШапкиДокумента)
	
	//Проверяем заполнение шапки
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("СчетКасса","Не указан счет учета денежных средств.");
	
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
	
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	
	Если СокрЛП(Номер)="" Тогда
		
		Предупреждение("Документ без номера не может быть проведен");
		Отказ=Истина;
		
	КонецЕсли;	

	Если Не Отказ Тогда
		ДвиженияПоРегистрам(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
	КонецЕсли;
	
КонецПроцедуры // ОбработкаПроведения

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
