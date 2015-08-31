# -*- coding: utf-8 -*-
__author__ = 'jpierzchlewicz'
from scrapy import Item, Field, Spider, Request

class Car(Item):
    title = Field()
    brand = Field()
    model = Field()
    production_year = Field()
    mileage = Field()
    version = Field()
    type = Field()
    color = Field()
    country_of_origin = Field()
    fuel_type = Field()
    power = Field()
    metallic = Field()
    first_registration = Field()
    collision_free = Field()
    location = Field()
    price = Field()
    aso_serviced = Field()


class CarSpider(Spider):

    name = "otomoto.pl"
    start_urls = ['http://otomoto.pl/osobowe/toyota/corolla/?search%5Bfilter_float_year%3Ato%5D=2005&search%5Bnew_used%5D=used']

    def parse(self, response):
        counter = 1
        url = response.xpath("//*[@id=\"body-container\"]/div[2]/div[1]/div/div[3]/div[3]/article["+str(counter)+"]/div[2]/div/h3/a/@href").extract()
        while len(url) > 0:
            url = url[0]
            if "otomoto" in url:
                yield Request(url, callback=self.parse_offer)
            counter += 1
            url = response.xpath("//*[@id=\"body-container\"]/div[2]/div[1]/div/div[3]/div[3]/article["+str(counter)+"]/div[2]/div/h3/a/@href").extract()

        next_page = response.xpath("//*[@class=\"next abs\"]/a/@href").extract()

        if len(next_page) > 0:
            yield Request(next_page[0], callback=self.parse)

    def parse_offer(self, response):
        car = Car()
        car['title'] = ''.join(response.xpath("//*[@id=\"siteWrap\"]/section/div[1]/header/div/div/div/h1/text()").extract()).strip()
        car['location'] = ''.join(response.xpath("//*[@class=\"address icon-lokalizacja\"]/text()").extract()[0]).strip()
        car['price'] = ''.join(response.xpath("//*[@id=\"siteWrap\"]/section/div[2]/div[1]/div/div[1]/div/div/span/text()").extract()).strip()
        label = ''.join(response.xpath("//*[@id=\"siteWrap\"]/section/div[2]/article/div/div/div[1]/div[1]/ul/li[1]/small/text()").extract()).strip()
        counter = 1
        while label:
            text = ''.join(response.xpath("//*[@id=\"siteWrap\"]/section/div[2]/article/div/div/div[1]/div[1]/ul/li["+str(counter)+"]/a/span/text()").extract()).strip()
            label = unicode(label).encode('utf8')
            text = unicode(text).encode('utf8')
            if label == "Marka":
                car['brand'] = text
            elif label == "Model":
                car['model'] = text
            elif label == "Wersja":
                car['version'] = text
            elif label == "Przebieg":
                car['mileage'] = ''.join(response.xpath("//*[@id=\"siteWrap\"]/section/div[2]/article/div/div/div[1]/div[1]/ul/li["+str(counter)+"]/span/text()").extract()).strip()
            elif label == "Kraj pochodzenia":
                car['country_of_origin'] = text
            elif label == "Bezwypadkowy":
                car['collision_free'] = text
            elif label == "Rodzaj paliwa":
                car['fuel_type'] = text
            elif label == "Moc":
                car['power'] = ''.join(response.xpath("//*[@id=\"siteWrap\"]/section/div[2]/article/div/div/div[1]/div[1]/ul/li["+str(counter)+"]/span/text()").extract()).strip()
            elif label == "Typ":
                car['type'] = text
            elif label == "Kolor":
                car['color'] = text
            elif label == "Pierwsza rejestracji":
                car['first_registration'] = ''.join(response.xpath("//*[@id=\"siteWrap\"]/section/div[2]/article/div/div/div[1]/div[1]/ul/li["+str(counter)+"]/span/text()").extract()).strip()
            elif label == "Serwisowany w ASO":
                car['aso_serviced'] = text
            elif label == "Metalik":
                car['metallic'] = text
            elif label == "Rok produkcji":
                car['production_year'] = ''.join(response.xpath("//*[@id=\"siteWrap\"]/section/div[2]/article/div/div/div[1]/div[1]/ul/li["+str(counter)+"]/span/text()").extract()).strip()

            counter += 1
            label = ''.join(response.xpath("//*[@id=\"siteWrap\"]/section/div[2]/article/div/div/div[1]/div[1]/ul/li["+str(counter)+"]/small/text()").extract()).strip()

        return car
