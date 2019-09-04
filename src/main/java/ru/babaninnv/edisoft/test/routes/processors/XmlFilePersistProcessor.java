package ru.babaninnv.edisoft.test.routes.processors;

import org.apache.camel.Exchange;
import org.apache.camel.Message;
import org.apache.camel.Processor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import ru.babaninnv.edisoft.test.domain.XmlFile;
import ru.babaninnv.edisoft.test.repositories.XmlFileRepository;

import java.util.Date;

@Component
public class XmlFilePersistProcessor implements Processor {

    private final XmlFileRepository xmlFileRepository;

    @Autowired
    public XmlFilePersistProcessor(XmlFileRepository xmlFileRepository) {
        this.xmlFileRepository = xmlFileRepository;
    }

    @Override
    public void process(Exchange exchange) {
        Message in = exchange.getIn();

        String originalFileName = (String) in.getExchange().getProperty("originalFileName");
        byte[] originalBody = (byte[]) in.getExchange().getProperty("originalBody");
        byte[] body = (byte[]) in.getBody();

        // подготавливает экземпляр класса XmlFile
        XmlFile xmlFile = new XmlFile();
        xmlFile.setOriginalName(originalFileName);
        xmlFile.setReceiveDate(new Date());
        xmlFile.setOriginalFile(originalBody);
        xmlFile.setTransformedFile(body);

        // сохранить запись с данными файла в БД
        xmlFileRepository.save(xmlFile);

        exchange.getOut().setBody(xmlFile);
    }
}
