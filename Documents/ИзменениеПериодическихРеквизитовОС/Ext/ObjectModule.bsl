﻿// Строки, хранят реквизиты имеющие смысл только для бух. учета и упр. соответственно
// в случае если документ не отражается в каком-то виде учета, делаются невидимыми
Перем мСтрокаРеквизитыНалУчета Экспорт; // (Регл)

Перем мУчетнаяПолитика;                 // (Общ)

Перем мВалютаРегламентированногоУчета Экспорт;

Перем мФормаДокумента Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда

// Процедура печати табличной части документа
//
Функция ПечатьОписи() Экспорт
	
	Если мФормаДокумента = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	// Список полей, по которым нужно выводить итоги.
	
	
	СписокИтоговыхПолей = Новый СписокЗначений();
	СписокИтоговыхПолей.Добавить("ПервоначальнаяСтоимостьБУ");
	СписокИтоговыхПолей.Добавить("СтоимостьБУ");
	СписокИтоговыхПолей.Добавить("НакопленнаяАмортизацияБУ");
	СписокИтоговыхПолей.Добавить("ПереоценкаБУ");
	
	
	ТабДок  = Новый ТабличныйДокумент;
	Макет   = ПолучитьМакет("ТабЧасть");
	Область = Макет.ПолучитьОбласть("Заголовок");
	Область.Параметры.Заголовок = Метаданные().Представление() + " № " + Номер + " от " + Формат( Дата, "ДФ=dd.MM.yyyy");
	ТабДок.Вывести( Область);
	
	Область = Макет.ПолучитьОбласть("ШапкаБух");
	Область.Параметры.Организация              = Организация;
	ТабДок.Вывести( Область);
	
	// Создадим структуру печатаемых реквизитов
	МетаТЧ     = Метаданные().ТабличныеЧасти.ОС.Реквизиты;
	СтруктРекв = Новый Структура;
	СтруктРекв.Вставить("ОсновноеСредство", МетаТЧ.ОсновноеСредство);
	Для Каждого Колонка Из мФормаДокумента.ЭлементыФормы.ОС.Колонки Цикл
		Если Не (Колонка.Имя = "НомерСтроки" ИЛИ Колонка.Имя = "КодОС")
			   И Колонка.Видимость Тогда
			СтруктРекв.Вставить( Колонка.Имя, МетаТЧ[Колонка.Имя]);
		КонецЕсли;
	КонецЦикла;
	
	// Вывод заголовка таб части
	Область = Макет.ПолучитьОбласть( "ТабШапка|Начало");
	ТабДок.Вывести( Область);
	Область = Макет.ПолучитьОбласть( "ТабШапка|Колонка");
	Для Каждого Колонка Из СтруктРекв Цикл
		Если Не Колонка.Ключ = "ОсновноеСредство" Тогда
			Область.Параметры.КолЗаголовок = Колонка.Значение;
			ТабДок.Присоединить(Область);
		КонецЕсли;
	КонецЦикла;
	
	// Вывод данных
	Для Каждого СтрокаТЧ Из ОС Цикл
		Область = Макет.ПолучитьОбласть( "ТабСтрока|Начало");
		Область.Параметры.НомерСтроки = СтрокаТЧ.НомерСтроки;
		Область.Параметры.ОС          = СтрокаТЧ.ОсновноеСредство;
		ТабДок.Вывести( Область);
		
		Область = Макет.ПолучитьОбласть( "ТабСтрока|Колонка");
		Для Каждого Колонка Из СтруктРекв Цикл
			
			//Если не Колонки[Колонка.Ключ].Видимость Тогда
			//	Продолжить;
			//КонецЕсли; 
			
			Если Не Колонка.Ключ = "ОсновноеСредство" Тогда
				Область.Параметры.КолДанные = СтрокаТЧ[Колонка.Ключ];
				Если ТипЗнч(СтрокаТЧ[Колонка.Ключ]) = Тип("Булево") Тогда
					Область.ТекущаяОбласть.Формат = "БЛ=Нет; БИ=Да";
				ИначеЕсли ТипЗнч(СтрокаТЧ[Колонка.Ключ]) = Тип("Дата") Тогда
					Область.ТекущаяОбласть.Формат = "ДЛФ=DD";
				ИначеЕсли ТипЗнч(СтрокаТЧ[Колонка.Ключ]) = Тип("Число") Тогда
					//Формат числового значения
					Разрядность = 0;
					РазрядностьДробнойЧасти = 0;
					Если Колонка.Значение.Тип.СодержитТип(Тип("Число")) тогда
						Разрядность = Колонка.Значение.Тип.КвалификаторыЧисла.Разрядность;
						РазрядностьДробнойЧасти = Колонка.Значение.Тип.КвалификаторыЧисла.РазрядностьДробнойЧасти;
					КонецЕсли;
					СтрокаФормата = ?(Разрядность=0,"","ЧЦ="+Разрядность+";")+?(РазрядностьДробнойЧасти=0,"","ЧДЦ="+РазрядностьДробнойЧасти);				
					
					Область.ТекущаяОбласть.Формат = СтрокаФормата;
				КонецЕсли;
				ТабДок.Присоединить(Область);
			КонецЕсли;
		КонецЦикла;
		
	КонецЦикла;
	
	// Вывод итогов
	Область = Макет.ПолучитьОбласть( "ТабИтог|Начало");
	ТабДок.Вывести( Область);
	
	Область = Макет.ПолучитьОбласть( "ТабИтог|Колонка");
	Для Каждого Колонка Из СтруктРекв Цикл
		Если Колонка.Ключ = "ОсновноеСредство" Тогда
			Продолжить;
		КонецЕсли;
		Если Колонка.Значение.Тип.Типы()[0] = Тип("Число") 
		   И НЕ (СписокИтоговыхПолей.НайтиПоЗначению(Колонка.Ключ) = Неопределено) Тогда
			//Формат числового значения
			РазрядностьДробнойЧасти = Колонка.Значение.Тип.КвалификаторыЧисла.РазрядностьДробнойЧасти;
			СтрокаФормата = ?(РазрядностьДробнойЧасти=0,"","ЧДЦ="+РазрядностьДробнойЧасти+";");				
			Область.Параметры.КолИтог = ОС.Итог( Колонка.Ключ);
			Область.ТекущаяОбласть.Формат = СтрокаФормата+"ЧРД=,; ЧРГ=; ЧГ=3,0";
		Иначе
			Область.Параметры.КолИтог = "";
		КонецЕсли;
		ТабДок.Присоединить(Область);
	КонецЦикла;
	
	ТабДок.ТолькоПросмотр      = Истина;
	ТабДок.ОтображатьСетку     = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	Возврат ТабДок;
	
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
	
	Если ИмяМакета = "Опись" Тогда
		// Получить экземпляр документа на печать
		ТабДокумент = ПечатьОписи();
		
	КонецЕсли;
	
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, СформироватьЗаголовокДокумента(ЭтотОбъект), НепосредственнаяПечать);
	
КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("","");

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

// Процедура заполняет структуры именами реквизитов, которые имеют смысл
// только для определенного вида учета
//
Процедура ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчета() Экспорт
	
	//ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчетаНал();
	
КонецПроцедуры // ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчета()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Процедура проверяет корректность заполнения реквизитов шапки документа
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)
	
	// Укажем, что надо проверить:
	СтрРекв = "Организация";
					
	// Теперь вызовем общую процедуру проверки.
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, Новый Структура(СтрРекв), Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Процедура проверяет корректность заполнения реквизитов таб. части документа
//
Процедура ПроверитьЗаполнениеТабЧасти(СтруктураШапкиДокумента, Отказ, Заголовок);

	ОбязательныеРеквизиты = "ОсновноеСредство,СпособОтраженияРасходовПоАмортизации";
	
	ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "ОС", Новый Структура(ОбязательныеРеквизиты), Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеТабЧасти()


// Процедура формирования движений по регистру Начисление амортизации бух.
//
Процедура ДвижениеПоРегиструНачислениеАмортизацииБух( ТабОС, СтруктураШапкиДокумента, Заголовок)
		
	НаборДвижений   = Движения.НачислениеАмортизацииОСБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период               = Дата;
		НоваяСтрока.Организация          = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство     = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.НачислятьАмортизацию = СтрокаОС.НачислятьАмортизациюБУ;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструНачислениеАмортизацииБух()


// Процедура формирования движений по регистру ПараметрыАмортизации ОС бух.
//
Процедура ДвижениеПоРегиструПараметрыАмортизацииБух( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.ПараметрыАмортизацииОСБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период           = Дата;
		НоваяСтрока.Организация      = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.КоэффициентАмортизации                      = СтрокаОС.КоэффициентАмортизацииБУ;
		НоваяСтрока.КорректирующийКоэффициент                   = СтрокаОС.КорректирующийКоэффициент;
		НоваяСтрока.ПараметрВыработкиОС                   = СтрокаОС.ПараметрВыработкиОС;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструПараметрыАмортизацииБух()
////////////////////////////////////////////////////////////////////////////////

Процедура ДвижениеПоРегиструПервоначальныеСведения( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.ПервоначальныеСведенияОСБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период           = Дата;
		НоваяСтрока.Организация      = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.СпособПоступления = СтрокаОС.СпособПоступления;
		НоваяСтрока.СпособНачисленияАмортизации = СтрокаОС.СпособНачисленияАмортизации;
		НоваяСтрока.ПорядокПогашенияСтоимости = СтрокаОС.ПорядокПогашенияСтоимости;
		НоваяСтрока.ПротивопожарныеОС = СтрокаОС.ПротивопожарныеОС;
		НоваяСтрока.ОСПоОхранеОкружающейСреды = СтрокаОС.ОСПоОхранеОкружающейСреды;
		НоваяСтрока.Состояние = СтрокаОС.Состояние;
		НоваяСтрока.ГруппаОборудования = СтрокаОС.ГруппаОборудования;
		
		
		Если НачалоДня(Дата)<=дата(2008,12,31) Тогда
			
			НоваяСтрока.ГруппаОС=СтрокаОС.ОсновноеСредство.ГруппаОС1;
		Иначе	
			
			Срез=РегистрыСведений.ПервоначальныеСведенияОСБухгалтерскийУчет.СрезПоследних(Дата,Новый Структура("Организация,ОсновноеСредство",Организация,СтрокаОС.ОсновноеСредство));
			
			Если Срез.Количество()>0 Тогда
				НоваяСтрока.ГруппаОС=Срез[0].ГруппаОС;
			КонецЕсли; 
		КонецЕсли; 
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструПараметрыАмортизацииБух()
////////////////////////////////////////////////////////////////////////////////

Процедура ДвижениеПоРегиструЛьготныеОС( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.ЛьготныеОсновныеСредства;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период               = Дата;
		НоваяСтрока.Организация          = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство     = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Льгота               = СтрокаОС.Льгота;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры
////////////////////////////////////////////////////////////////////////////////

Процедура ДвижениеПоРегиструЛизинговыеОС( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.ЛизинговыеОсновныеСредства;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период               = Дата;
		НоваяСтрока.Организация          = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство     = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Лизинг               = СтрокаОС.Лизинг;
		НоваяСтрока.СрокМесяцев          = СтрокаОС.ЛизингСрокМесяцев;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструНачислениеАмортизацииБух()
////////////////////////////////////////////////////////////////////////////////

Процедура ДвижениеПоРегиструСпособыОтраженияБух	     ( ТабОС, СтруктураШапкиДокумента, Заголовок)
		
	НаборДвижений   = Движения.СпособыОтраженияРасходовПоАмортизацииОСБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		Если ЗначениеНеЗаполнено(СтрокаОС.СпособОтраженияРасходовПоАмортизации) тогда
			Продолжить;
		КонецЕслИ;
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период            = СтруктураШапкиДокумента.Дата;
		НоваяСтрока.ОсновноеСредство  = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Организация       = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.СпособыОтраженияРасходовПоАмортизации = СтрокаОС.СпособОтраженияРасходовПоАмортизации;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструСпособыОтраженияБух()

// Процедура формирования движений по регистрам.
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, Отказ,Заголовок)

	ТабОС = ОС.Выгрузить();
	
	ДвижениеПоРегиструНачислениеАмортизацииБух   ( ТабОС, СтруктураШапкиДокумента, Заголовок);
	ДвижениеПоРегиструПараметрыАмортизацииБух    ( ТабОС, СтруктураШапкиДокумента);
	ДвижениеПоРегиструСпособыОтраженияБух	     ( ТабОС, СтруктураШапкиДокумента, Заголовок);
	ДвижениеПоРегиструПервоначальныеСведения     ( ТабОС, СтруктураШапкиДокумента);
	ДвижениеПоРегиструЛьготныеОС                 ( ТабОС, СтруктураШапкиДокумента);
	ДвижениеПоРегиструЛизинговыеОС               ( ТабОС, СтруктураШапкиДокумента);
	
КонецПроцедуры // ДвиженияПоРегистрам()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОшибкаПроведенияПоСтроке(СтрокаОС, ТекстСообщения,Заголовок,Статус)
	НачалоСообщения = "- строка № "+СтрокаОС.НомерСтроки+", инв. номер ОС <"+СтрокаОС.ОсновноеСредство.ИнвентарныйНомер+"> : ";
	СообщитьОбОшибке(НачалоСообщения+ТекстСообщения, ,Заголовок ,Статус)
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ)

	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчета();

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);
	//ПроверитьЗаполнениеТабЧасти(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("ОсновноеСредство", "ОсновноеСредство");
	СтруктураПолей.Вставить("НомерСтроки",      "НомерСтроки");
	//СтруктураПолей.Вставить("ИнвентарныйНомер", "ИнвентарныйНомер");

	РезультатЗапросаПоОС = СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "ОС", СтруктураПолей);
	ТаблицаПоОС          = РезультатЗапросаПоОС.Выгрузить();
	
	// Проверим, нет ли повторяющихся основных средств в таблице по ОС.
	ПроверитьДублиОС(ТаблицаПоОС, Отказ, Заголовок);

	// Проверим, нет ли одинаковых инвентарных номеров основных средств в таблице по ОС.
	//ПроверитьДублиИнвентарныхНомеровОС(ТаблицаПоОС, Отказ, Заголовок);
	
	Если НЕ Отказ Тогда
		
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, Отказ, Заголовок);
		
	КонецЕсли;
	
КонецПроцедуры // ОбработкаПроведения()

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	
	СписокОС        = ОС.ВыгрузитьКолонку("ОсновноеСредство");
	МоментДокумента = Новый МоментВремени(Дата, Ссылка);
	
	ТЗ = ЗаполнитьТаблицуПериодическихРеквизитовОС(Организация, СписокОС, МоментДокумента);
	
	
	Если ТЗ.Количество() > 0 Тогда
		
		Для Каждого Строка Из ОС Цикл
			
			СтрокаТЗ = ТЗ.Найти(Строка.ОсновноеСредство, "ОсновноеСредство");
			
			Если ?(СтрокаТЗ = Неопределено, Истина, СтрокаТЗ.СнятоСУчетаБУ) Тогда
				
				Если СтрокаТЗ = Неопределено Тогда
					СообщитьОбОшибке("Основное средство <"+Строка.ОсновноеСредство+"> не отражалось в учете (БУ) по указанной организации.",,, СтатусСообщения.Важное);
				Иначе
					СообщитьОбОшибке("Основное средство <"+Строка.ОсновноеСредство+"> снято с учета (БУ) в указанной организации.",,, СтатусСообщения.Важное);
				КонецЕсли;
				
				Отказ=истина;
			КонецЕсли;
			
		КонецЦикла;
		
	Иначе
	КонецЕсли;
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
мФормаДокумента = Неопределено;