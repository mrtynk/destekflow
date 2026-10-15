require "set"

module Tickets
  class Similarity
    Result = Data.define(:ticket, :score, :matched_terms)

    THRESHOLD = 30
    MINIMUM_MATCHED_TERMS = 2
    STOP_WORDS = %w[
      acaba ama ancak artık ben beni benim bir bize bu çünkü daha da de diye en gibi için ile ise
      ki mi mı mu mü nasıl ne neden o olan olarak oldu olabilir onun şu ve veya ya yani yine
      destek hata sorun talep yardım
    ].to_set.freeze

    def self.call(ticket, candidates: Ticket.where.not(id: ticket.id))
      new(ticket, candidates:).call
    end

    def initialize(ticket, candidates:)
      @ticket = ticket
      @candidates = candidates
    end

    def call
      source_terms = terms_for(ticket)

      candidates.filter_map do |candidate|
        candidate_terms = terms_for(candidate)
        matched = (source_terms & candidate_terms).sort
        union = source_terms | candidate_terms
        score = union.empty? ? 0 : ((matched.length.to_f / union.length) * 100).round
        next if score < THRESHOLD || matched.length < MINIMUM_MATCHED_TERMS

        Result.new(ticket: candidate, score:, matched_terms: matched)
      end.sort_by { |result| [ -result.score, result.ticket.id ] }
    end

    def self.normalize(text)
      text.to_s.unicode_normalize(:nfd).downcase.gsub(/\p{Mn}/, "").tr("ı", "i").gsub(/[^\p{Alnum}\s]/, " ")
    end

    private

    attr_reader :ticket, :candidates

    def terms_for(candidate)
      self.class.normalize("#{candidate.subject} #{candidate.description}")
        .split
        .select { |term| term.length >= 3 && !STOP_WORDS.include?(term) }
        .to_set
    end
  end
end
