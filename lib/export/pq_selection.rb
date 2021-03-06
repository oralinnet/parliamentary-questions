module Export
  class PqSelection < Base

    DATE_FORMAT  = '%Y-%m-%d %H:%M'

    HEADINGS = [
      'PIN',
    'MP',
    'Draft due to Parly Branch',
    'Date Due in Parliament',
    'Full_PQ_subject',
    'Minister',
    'Status',
    'Action Officer',
    'Division',
    'Type of Question',
    'Date First Appeared in Parliament',
    'Date Draft Returned to PB',
    'Date delivered to Minister',
    'Returned signed from Minister',
    'Date response answered by Parly (dept)'
    ]

    def csv_fields(pq, ao)
      [ pq.uin,                                                         # 'PIN',
        pq.member_name,                                                 # 'MP',
        empty_or_date(pq.internal_deadline),                     # 'Draft due to Parly Branch',
        empty_or_date(pq.date_for_answer),                       # 'Date Due in Parliament',
        pq.question,                                                    # 'Full_PQ_subject',
        pq.minister && pq.minister.name,                                # 'Minister',
        PQState.state_label(pq.state),
        ao && ao.name,                                                  # 'Action Officer',
        pq.original_division && pq.original_division.name,              # 'Division',
        pq.question_type,                                               # 'Type of Question',
        empty_or_date(pq.tabled_date),                           # 'Date First Appeared in Parliament',
        empty_or_date(pq.draft_answer_received),                 # 'Date Draft Returned to PB',
        empty_or_date(pq.sent_to_answering_minister),            # 'Date delivered to Minister',
        empty_or_date(pq.cleared_by_answering_minister),         # 'Returned signed from Minister',
        empty_or_date(pq.answer_submitted)                       # 'Date response answered by Parly (dept)',
      ]
    end

    def empty_or_date(this_date)
      if this_date.nil?
         ''
      else
        this_date.strftime('%Y-%m-%d %H:%M')
      end
    end

    def to_csv
      CSV.generate do |csv|
        csv << HEADINGS
        pqs.each { |pq| csv << csv_fields(pq, pq.action_officer_accepted) }
      end
    end

    private
    def pqs
        pqs_array = Array.new
        @pqs_list.split(',').map { |p|
          if Pq.find_by(uin: p).nil?
            puts 'Failed to validate ' || p
            return pqs_array
          else
            puts 'Validated ' || p
            x = Pq.find_by(uin: p)
            puts x
            pqs_array.push(x)
          end
        } unless @pqs_list.nil?
        pqs_array

    end
  end
end
