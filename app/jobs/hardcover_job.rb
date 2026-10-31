class HardcoverJob < ApplicationJob
  
  def perform
    defer_retry('hardcover', 12) { get_hardcover }
  end

  private

  # see https://docs.hardcover.app/api/getting-started/
  def get_hardcover
    Rails.logger.debug "Fetching Hardcover checkins via API..."
    parsed_items = []
    books = []

    book_details = <<-GRAPHQL
      {
        book {
          title
          image {
            url
          }
          slug
        }
        first_read_date
        last_read_date
        updated_at
        status_id
      }
    GRAPHQL

    # first get currently reading books
    query = {
              query: <<-GRAPHQL
                {
                  user_books(
                    order_by: {first_started_reading_date: desc}
                    where: {user_id: {_eq: #{Rails.application.credentials.hardcover['id']}}, status_id: {_eq: 2}}
                    limit: 20
                  ) #{book_details}
                }
              GRAPHQL
            }.to_json
    currently_reading = make_request('https://api.hardcover.app/v1/graphql', auth_token: Rails.application.credentials.hardcover['api_key'], body: query)
    books << currently_reading['data']['user_books']

    # then add finished reading books
    query = {
              query: <<-GRAPHQL
                {
                  user_books(
                    order_by: {last_read_date: desc_nulls_last}
                    where: {user_id: {_eq: #{Rails.application.credentials.hardcover['id']}}, status_id: {_eq: 3}}
                    limit: 20
                  ) #{book_details}
                }
              GRAPHQL
            }.to_json
    finished_reading = make_request('https://api.hardcover.app/v1/graphql', auth_token: Rails.application.credentials.hardcover['api_key'], body: query)
    books << finished_reading['data']['user_books']

    books.flatten.each do |book|
      title = book['book']['title']
      url = "https://hardcover.app/books/#{book['book']['slug']}"
      date =  if !book['last_read_date'].blank?
                book['last_read_date']
              elsif !book['first_read_date'].blank?
                book['first_read_date']
              else
                book['updated_at']
              end
      image = if !book['book']['image'].blank? && !book['book']['image']['url'].blank?
                store_local_copy(book['book']['image']['url'], 'hardcover', normalize_title(title))
              else
                false
              end
      parsed_items << {
        title:     title,
        url:       url,
        published: date.to_datetime,
        image_url: image
      }
    end
    unless parsed_items.blank?
      Rails.cache.write('hardcover', parsed_items)
      keep_titles = parsed_items.collect{|item| normalize_title(item.title)}
      clear_local_copies('hardcover', keep_titles)
    end
  end
  
end