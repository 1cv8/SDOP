///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Сертификат = Параметры.Сертификат;
	
	ЗаявлениеНаВыпускСертификатаДоступно = ЭлектроннаяПодпись.ОбщиеНастройки().ЗаявлениеНаВыпускСертификатаДоступно;
	Если ЗаявлениеНаВыпускСертификатаДоступно И ЗначениеЗаполнено(Сертификат) Тогда
		ОбработкаЗаявлениеНаВыпускНовогоКвалифицированногоСертификата = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(
			"Обработка.ЗаявлениеНаВыпускНовогоКвалифицированногоСертификата");
		ВыпущенныеСертификаты = ОбработкаЗаявлениеНаВыпускНовогоКвалифицированногоСертификата.ВыпущенныеСертификаты(
			Сертификат);
	КонецЕсли;
	ЕстьПеревыпущенные = ВыпущенныеСертификаты.Количество() > 0;
	Элементы.ДекорацияПеревыпущен.Видимость = ЕстьПеревыпущенные;
	
	ЗаявлениеНаВыпускСертификатаДоступно = ЗаявлениеНаВыпускСертификатаДоступно
		И ПравоДоступа("Редактирование", Метаданные.Справочники.СертификатыКлючейЭлектроннойПодписиИШифрования);
		
	ДополнительныеДанныеПроверки = Параметры.ДополнительныеДанныеПроверки; // см. ЭлектроннаяПодписьСлужебныйКлиентСервер.ПредупреждениеПриПроверкеУдостоверяющегоЦентраСертификата
	
	Если ЗначениеЗаполнено(ДополнительныеДанныеПроверки) И ТипЗнч(ДополнительныеДанныеПроверки) = Тип("Структура") Тогда
		
		Элементы.ДекорацияСертификат.Заголовок = ДополнительныеДанныеПроверки.ТекстОшибки;
		Если ЗначениеЗаполнено(ДополнительныеДанныеПроверки.Причина) Тогда
			Элементы.ДекорацияПричина.Заголовок = ДополнительныеДанныеПроверки.Причина;
			Элементы.ДекорацияПричина.Видимость = Истина;
		КонецЕсли;
		
		Если Не ЕстьПеревыпущенные Тогда
			Если ДополнительныеДанныеПроверки.ВозможенПеревыпуск И Не ЗаявлениеНаВыпускСертификатаДоступно Тогда
				Элементы.ДекорацияРешение.Заголовок = Решение();
				Элементы.ДекорацияРешение.Видимость = Истина;
			Иначе
				Если ЗначениеЗаполнено(ДополнительныеДанныеПроверки.Решение) Тогда
					Элементы.ДекорацияРешение.Заголовок = ДополнительныеДанныеПроверки.Решение;
					Элементы.ДекорацияРешение.Видимость = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
	Иначе
		
		Если ЗначениеЗаполнено(Сертификат) Тогда
			ДействителенДо = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Сертификат, "ДействителенДо")
				+ ЭлектроннаяПодписьСлужебный.ДобавкаВремени();
			Элементы.ДекорацияСертификат.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru='%1 закончится срок действия сертификата'"), ДействителенДо);
			Если Не ЕстьПеревыпущенные Тогда
				Если ЗаявлениеНаВыпускСертификатаДоступно Тогда
					Решение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Подайте <a href = ""%1"">заявление</a> на новый сертификат.'"),
						"ПодатьЗаявлениеНаСертификат");
				Иначе
					Решение = Решение();
				КонецЕсли;

				Элементы.ДекорацияРешение.Заголовок = СтроковыеФункции.ФорматированнаяСтрока(Решение);
				Элементы.ДекорацияРешение.Видимость = Истина;
			КонецЕсли;
		Иначе
			Элементы.ДекорацияСертификат.Заголовок = НСтр("ru = 'Не заполнен параметр Сертификат при открытии формы.'");
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура БольшеНеНапоминатьПриИзменении(Элемент)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ИзменитьОтметкуОНапоминании(Сертификат, Не БольшеНеНапоминать, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияПеревыпущенОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если ВыпущенныеСертификаты.Количество() = 1 Тогда
		ОткрытьСертификатПослеВыбораИзСписка(ВыпущенныеСертификаты[0], Неопределено);
	Иначе	
		ОписаниеОповещения = Новый ОписаниеОповещения("ОткрытьСертификатПослеВыбораИзСписка", ЭтотОбъект, Элемент);
		ПоказатьВыборИзСписка(ОписаниеОповещения, ВыпущенныеСертификаты);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияРешениеОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	ДополнительныеДанные = ЭлектроннаяПодписьСлужебныйКлиент.ДополнительныеДанныеДляКлассификатораОшибок();
	ДополнительныеДанные.Сертификат = Сертификат;
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьНавигационнуюСсылкуКлассификатора(
		Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка, ДополнительныеДанные);
		
КонецПроцедуры

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОткрытьСертификатПослеВыбораИзСписка(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено Тогда
		ОткрытьФорму("Справочник.СертификатыКлючейЭлектроннойПодписиИШифрования.ФормаОбъекта", 
			Новый Структура("Ключ", Результат.Значение));
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Функция Решение()
	
	Если ЭлектроннаяПодпись.ОбщиеНастройки().ДоступнаПроверкаПоСпискуУЦ Тогда
		МодульЭлектроннаяПодписьКлиентСерверЛокализация = ОбщегоНазначения.ОбщийМодуль(
			"ЭлектроннаяПодписьКлиентСерверЛокализация");
		Возврат СтроковыеФункции.ФорматированнаяСтрока(
				НСтр("ru = 'Получите новый сертификат в <a href = ""%1"">соответствующем удостоверяющем центре</a>.'"),
					МодульЭлектроннаяПодписьКлиентСерверЛокализация.СсылкаНаСтатьюОбУдостоверяющихЦентрах());
	Иначе
		Возврат НСтр("ru = 'Получите новый сертификат.'");
	КонецЕсли;
	
КонецФункции

#КонецОбласти