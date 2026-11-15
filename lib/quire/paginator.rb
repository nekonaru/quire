# frozen_string_literal: true

module Quire
  # Computes page lists for paginated post indexes.
  class Paginator
    Page = Struct.new(:number, :url, keyword_init: true)

    attr_reader :total_count, :per_page, :current_page

    def initialize(total_count, per_page, current_page = 1)
      @total_count = total_count
      @per_page = [per_page.to_i, 1].max
      @current_page = current_page
    end

    def total_pages
      [(@total_count.to_f / @per_page).ceil, 1].max
    end

    def slice(items)
      items[(@current_page - 1) * @per_page, @per_page] || []
    end

    def first? = @current_page == 1
    def last? = @current_page >= total_pages

    def prev_url
      return nil if first?

      url_for(@current_page - 1)
    end

    def next_url
      return nil if last?

      url_for(@current_page + 1)
    end

    # URL for a page number; "/" for the first page (site root).
    def self.url_for(number)
      number <= 1 ? "/" : "/page/#{number}/"
    end

    def url_for(number) = self.class.url_for(number)

    def page_urls
      (1..total_pages).map { |n| url_for(n) }
    end
  end
end
