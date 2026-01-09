json.extract! job_offer, :id, :title, :company, :location, :contract_type, :remote, :salary, :description, :contact_phone, :active, :created_at, :updated_at
json.url job_offer_url(job_offer, format: :json)
