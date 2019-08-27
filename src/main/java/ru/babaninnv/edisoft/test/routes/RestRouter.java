package ru.babaninnv.edisoft.test.routes;


import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.model.rest.RestBindingMode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;

import ru.babaninnv.edisoft.test.domain.XmlFile;

import static org.apache.camel.model.rest.RestParamType.path;

/**
 * Роутер для обработки REST-запросов
 *
 * @author Nikita Babanin
 * @version 1.0
 */
@Component
public class RestRouter extends RouteBuilder {

    private final Environment env;

    @Value("${camel.component.servlet.mapping.contextPath}")
    private String contextPath;

    public RestRouter(Environment env) {
        this.env = env;
    }

    @Override
    public void configure() {
        // конфигурация REST-сервиса
        restConfiguration()
                .component("servlet")
                .bindingMode(RestBindingMode.json)
                .dataFormatProperty("prettyPrint", "true")
                .port(env.getProperty("server.port", "8080"))
                .contextPath(contextPath.substring(0, contextPath.length() - 2))
                .apiContextPath("/api-doc")
                .apiProperty("api.title", "User API")
                .apiProperty("api.version", "1.0.0");


        rest("/files").description("Сервис для работы с файлами")

                // REST-сервис для получения информации о всех XML-файлах в формате JSON
                .get().description("Получение списка всех файлов").outType(XmlFile[].class)
                .produces(MediaType.APPLICATION_JSON_VALUE)
                .responseMessage().code(200).message("Все файлы успешно загружены").endResponseMessage()
                .to("bean:xmlFileService?method=findAll")

                // REST-сервис для загрузки вложения по идентификатору
                .get("/download/{id}").description("Получение конвертированого файла")
                .param().name("id").type(path).dataType("long").endParam()
                .produces(MediaType.APPLICATION_OCTET_STREAM_VALUE)
                .route()
                .to("bean:xmlFileService?method=getTransformedFile(${header.id})")
                .setHeader("Content-Disposition", simple("attachment;filename=transformed-${body.originalName}"))
                .setBody(simple("${body.transformedFile}"));
    }

}