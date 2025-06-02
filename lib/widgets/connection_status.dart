import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class ConnectionStatus extends StatefulWidget {
  const ConnectionStatus({super.key});

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  bool _isConnected = true;
  bool _isChecking = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return;
    
    setState(() {
      _isChecking = true;
    });

    try {
      final isConnected = await _apiService.testConnection();
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected && !_isChecking) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isChecking 
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: _isChecking ? AppColors.warning : AppColors.error,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_isChecking)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
              ),
            )
          else
            Icon(
              Icons.wifi_off,
              size: 16,
              color: AppColors.error,
            ),
          
          const SizedBox(width: 8),
          
          Expanded(
            child: Text(
              _isChecking 
                  ? 'Memeriksa koneksi...'
                  : 'Tidak dapat terhubung ke server',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _isChecking ? AppColors.warning : AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          if (!_isChecking)
            TextButton(
              onPressed: _checkConnection,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Coba Lagi',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ConnectionStatusProvider extends StatefulWidget {
  final Widget child;
  
  const ConnectionStatusProvider({
    super.key,
    required this.child,
  });

  @override
  State<ConnectionStatusProvider> createState() => _ConnectionStatusProviderState();
}

class _ConnectionStatusProviderState extends State<ConnectionStatusProvider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ConnectionStatus(),
        Expanded(child: widget.child),
      ],
    );
  }
}
