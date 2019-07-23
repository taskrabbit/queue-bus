# frozen_string_literal: true

require 'spec_helper'

describe 'QueueBus config' do
  it 'sets the default app key' do
    expect(QueueBus.default_app_key).to eq(nil)

    QueueBus.default_app_key = 'my_app'
    expect(QueueBus.default_app_key).to eq('my_app')

    QueueBus.default_app_key = 'something here'
    expect(QueueBus.default_app_key).to eq('something_here')
  end

  it 'sets the default queue' do
    expect(QueueBus.default_queue).to eq(nil)

    QueueBus.default_queue = 'my_queue'
    expect(QueueBus.default_queue).to eq('my_queue')
  end

  it 'sets the local mode' do
    expect(QueueBus.local_mode).to eq(nil)
    QueueBus.local_mode = :standalone
    expect(QueueBus.local_mode).to eq(:standalone)
  end

  it 'sets the hostname' do
    expect(QueueBus.hostname).not_to eq(nil)
    QueueBus.hostname = 'whatever'
    expect(QueueBus.hostname).to eq('whatever')
  end

  it 'sets before_publish callback' do
    QueueBus.before_publish = ->(_attr) { 42 }
    expect(QueueBus.before_publish_callback({})).to eq(42)
  end

  it 'uses the default Redis connection' do
    expect(QueueBus.redis { |redis| redis }).not_to eq(nil)
  end

  it 'defaults to given adapter' do
    expect(QueueBus.adapter.is_a?(adapter_under_test_class)).to eq(true)

    # and should raise if already set
    expect { QueueBus.adapter = :data }
      .to raise_error(RuntimeError, 'Adapter already set to QueueBus::Adapters::Data')
  end

  context 'with a fresh load' do
    before(:each) do
      QueueBus.send(:reset)
    end

    context 'when set to adapter under test' do
      before do
        QueueBus.adapter = adapter_under_test_symbol
      end

      it 'sets to that adapter' do
        expect(QueueBus.adapter).to be_a adapter_under_test_class
      end
    end

    context 'when already set' do
      before do
        QueueBus.adapter = :data
      end

      it 'raises' do
        expect { QueueBus.adapter = :data }
          .to raise_error(RuntimeError, 'Adapter already set to QueueBus::Adapters::Data')
      end

      it 'knows the adapter is set' do
        expect(QueueBus).to have_adapter
      end
    end

    context 'with a symbol' do
      before do
        QueueBus.adapter = :data
      end

      it 'looks up the known class' do
        expect(QueueBus.adapter).to be_a QueueBus::Adapters::Data
      end
    end

    context 'with a custom adapter' do
      let(:klass) do
        Class.new(QueueBus::Adapters::Base) do
          def enabled!
            # no op
          end

          def redis
            # no op
          end
        end
      end

      before do
        QueueBus.adapter = klass.new
      end

      it 'sets it to something else' do
        expect(QueueBus.adapter).to be_a klass
      end
    end

    context 'with a class' do
      before do
        QueueBus.adapter = QueueBus::Adapters::Data
      end

      it 'creates a new one' do
        expect(QueueBus.adapter).to be_a QueueBus::Adapters::Data
      end
    end
  end
end
