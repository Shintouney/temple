ready = ->

  addBasket = (article) ->
    $('#basket').find("ul.list-group").append '<li class="list-group-item" data-article-price="' + article.data("article-price") + '">'\
      + article.data("article-name")\
      + '<button type="button" class="pull-right btn btn-danger btn-xs m-left-sm">&times;</button>'\
      + '<span class="pull-right">' + String(article.data("article-price")).replace('.',',') + ' €</span>' \
      + '<input type="hidden" value="' + article.data("article-id") + '" name="order[order_items_attributes][][product_id]">'\
      + '</li>'

  totalBasket = ->
    total = 0
    basket = $('#basket')
    basket.find('.list-group-item').each (index, item) ->
      total += parseFloat $(this).data('article-price')

    $('#basket_total').text total.toFixed(2).replace('.',',')

    basket.find('.well').toggle $('#basket .list-group-item').length <= 0


  $('#articles-catalog').on 'click', '.well', ->
    addBasket $(this)
    totalBasket()

  $("#basket").on "click", ".btn-danger", ->
    $(this).closest("li").remove()
    totalBasket()
  
  $("form").submit ->
    $("#order_direct_payment").removeAttr "disabled"

$(document).ready(ready)