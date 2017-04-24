require_relative '../spec_helper'
describe Chronos::Settings do

  before :each do
    Setting.plugin_redmine_chronos = {
        round_minimum: '0.25',
        round_limit: '50',
        round_default: false,
        projects: {
            '1': {
                round_minimum: '0.4',
                round_default: true
            },
            '2': {
                round_minimum: '1',
                round_limit: '100',
                test: true
            }
        }
    }
  end

  describe 'global' do
    it 'returns the complete settings with projects specifics' do
      expect(described_class.global).to eql Setting.plugin_redmine_chronos
    end
  end

  describe 'project' do
    it 'returns exact settings for a specific project' do
      expect(described_class.project 1).to eql round_minimum: '0.4',
          round_default: true
    end

    it 'returns empty hash for unknown projects' do
      expect(described_class.project 3).to eql({})
    end
  end

  describe '[]' do
    describe 'without project' do
      it 'returns all settings' do
        expect(described_class[]).to eql round_minimum: '0.25',
            round_limit: '50',
            round_default: false
      end

      it 'returns a value for a key' do
        expect(described_class[:round_minimum]).to eql '0.25'
      end

      it 'returns nothing for unknown keys' do
        expect(described_class[:test]).to be_nil
      end
    end

    describe 'with project' do
      it 'returns active settings for a specific project' do
        expect(described_class[project: 1]).to eql round_minimum: '0.4',
            round_limit: '50',
            round_default: true
      end

      it 'returns a value for a key' do
        expect(described_class[:round_minimum, project: 1]).to eql '0.4'
      end

      it 'returns a value for a key only defined global' do
        expect(described_class[:round_limit, project: 1]).to eql '50'
      end

      it 'returns nothing for unknown keys' do
        expect(described_class[:test, project: 1]).to be_nil
      end
    end
  end

  describe '[]=' do
    describe 'without project' do
      it 'sets all settings without affecting project specifics' do
        described_class[] = {round_minimum: '0.1', round_limit: '60', round_default: true, new_setting: 10}
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.1',
            round_limit: '60',
            round_default: true,
            new_setting: 10,
            projects: {
                '1': {
                    round_minimum: '0.4',
                    round_default: true
                },
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                }
            }
      end

      it 'won\'t clear settings' do
        described_class[] = nil
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.25',
            round_limit: '50',
            round_default: false,
            projects: {
                '1': {
                    round_minimum: '0.4',
                    round_default: true
                },
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                }
            }
      end

      it 'sets a new value for a key without affecting project specifics' do
        described_class[:round_minimum] = '0.1'
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.1',
            round_limit: '50',
            round_default: false,
            projects: {
                '1': {
                    round_minimum: '0.4',
                    round_default: true
                },
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                }
            }
      end

      it 'adds a new value for a key without affecting project specifics' do
        described_class[:new_setting] = 10
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.25',
            round_limit: '50',
            round_default: false,
            new_setting: 10,
            projects: {
                '1': {
                    round_minimum: '0.4',
                    round_default: true
                },
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                }
            }
      end
    end

    describe 'with project' do
      it 'sets project settings without affecting anything else' do
        described_class[project: 1] = {round_minimum: '0.1', round_limit: '60', new_setting: 10}
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.25',
            round_limit: '50',
            round_default: false,
            projects: {
                '1': {
                    round_minimum: '0.1',
                    round_limit: '60',
                    round_default: true,
                    new_setting: 10,
                },
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                }
            }
      end

      it 'adds settings for a new project without affecting anything else' do
        described_class[project: 3] = {new_setting: 10}
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.25',
            round_limit: '50',
            round_default: false,
            projects: {
                '1': {
                    round_minimum: '0.4',
                    round_default: true
                },
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                },
                '3': {
                    new_setting: 10
                }
            }
      end

      it 'clears project settings without affecting anything else' do
        described_class[project: 1] = nil
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.25',
            round_limit: '50',
            round_default: false,
            projects: {
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                }
            }
      end

      it 'sets a value for a key without affecting anything else' do
        described_class[:round_minimum, project: 1] = '0.9'
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.25',
            round_limit: '50',
            round_default: false,
            projects: {
                '1': {
                    round_minimum: '0.9',
                    round_default: true
                },
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                }
            }
      end

      it 'adds a new value for a key without affecting anything else' do
        described_class[:new_setting, project: 1] = 10
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.25',
            round_limit: '50',
            round_default: false,
            projects: {
                '1': {
                    round_minimum: '0.4',
                    round_default: true,
                    new_setting: 10
                },
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                }
            }
      end

      it 'adds a new project for a key without affecting anything else' do
        described_class[:new_setting, project: 3] = 10
        expect(Setting.plugin_redmine_chronos).to eql round_minimum: '0.25',
            round_limit: '50',
            round_default: false,
            projects: {
                '1': {
                    round_minimum: '0.4',
                    round_default: true
                },
                '2': {
                    round_minimum: '1',
                    round_limit: '100',
                    test: true
                },
                '3': {
                    new_setting: 10
                }
            }
      end
    end
  end
end
