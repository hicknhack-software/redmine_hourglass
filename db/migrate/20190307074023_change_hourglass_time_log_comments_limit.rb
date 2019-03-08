ChangeHourglassTimeLogCommentsLimit = if Rails::VERSION::MAJOR <= 4
                                        Class.new(ActiveRecord::Migration) do
                                          def up
                                            change_column :hourglass_time_logs, :comments, :string, limit: 1024
                                          end

                                          def down
                                            change_column :hourglass_time_logs, :comments, :string
                                          end
                                        end
                                      else
                                        Class.new(ActiveRecord::Migration[4.2]) do
                                          def up
                                            change_column :hourglass_time_logs, :comments, :string, limit: 1024
                                          end

                                          def down
                                            change_column :hourglass_time_logs, :comments, :string
                                          end
                                        end
                                      end
