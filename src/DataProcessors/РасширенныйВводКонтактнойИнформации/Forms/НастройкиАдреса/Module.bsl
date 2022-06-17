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
	
	Если ТипЗнч(Параметры.Объект) = Тип("ДанныеФормыСтруктура") Тогда
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, Параметры.Объект);
	КонецЕсли;
	Элементы.Адрес.ТолькоПросмотр = Параметры.ТолькоПросмотр;
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		
		Элементы.Переместить(Элементы.ОК, Элементы.ФормаКоманднаяПанель);
		Элементы.Переместить(Элементы.Справка, Элементы.ФормаКоманднаяПанель);
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Отмена", "Видимость", Ложь);
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Справка", "ТолькоВоВсехДействиях", Истина);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ИзменитьОтображениеПриИзмененииТолькоНациональный();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура АдресТолькоНациональныйПриИзменении(Элемент)
	
	ИзменитьРеквизитыПриИзмененииТолькоНациональный();
	ИзменитьОтображениеПриИзмененииТолькоНациональный();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	Результат = ОписаниеНастроекАдреса();
	ЗаполнитьЗначенияСвойств(Результат, ЭтотОбъект);
	Закрыть(Результат);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ОписаниеНастроекАдреса()
	Результат = Новый Структура();
	Результат.Вставить("ТолькоНациональныйАдрес");
	Результат.Вставить("ПроверятьКорректность");
	Результат.Вставить("СкрыватьНеактуальныеАдреса");
	Результат.Вставить("УказыватьОКТМО");
	Результат.Вставить("ИсправлятьУстаревшиеАдреса");
	
	Возврат Результат;
КонецФункции

&НаКлиенте
Процедура ИзменитьОтображениеПриИзмененииТолькоНациональный()
	
	Элементы.ПроверятьКорректностьАдреса.Доступность = ТолькоНациональныйАдрес;
	Элементы.СкрыватьНеактуальныеАдреса.Доступность  = ТолькоНациональныйАдрес;
	Элементы.УказыватьОКТМОВручную.Доступность       = ТолькоНациональныйАдрес;
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьРеквизитыПриИзмененииТолькоНациональный()
	
	Если Не ТолькоНациональныйАдрес Тогда
		ПроверятьКорректность      = Ложь;
		СкрыватьНеактуальныеАдреса = Ложь;
		УказыватьОКТМО = Ложь;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти